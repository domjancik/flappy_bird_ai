require 'rubygems'
require 'gosu'

# Own classes
require_relative 'gamelements/bird'
require_relative 'gamelements/bird_brain'
require_relative 'gamelements/pipe'
require_relative 'gamelements/game_object_group'

module RFlappy
  class Game < Gosu::Window
    attr_reader :width, :height, :pipes, :font

    def world
      RFlappy::World
    end

    def initialize
      @width, @height = 1280, 864

      super(@width, @height, false)
      self.caption = 'Flappy Bird AI'

      world.game = self

      @background = Gosu::Image.new(self, 'media/bg.png')

      @birds = [ RFlappy::GameElements::Bird.new ]
      @bird_ais = []
      @pipes = []
      @all = [ @birds, @pipes, @bird_ais ]
      @time_to_pipe = 0

      @last_milliseconds = 0

      @font = Gosu::Font.new(self, 'Arial', 20)

      spawn_ai_bird
    end

    def draw
      @background.draw(0, 0, 0)

      @all.each { | group | group.each { | object | object.draw } }
    end

    # this is a callback for key up events or equivalent (there are
    # constants for gamepad buttons and mouse clicks)
    def button_up(key)
      self.close if key == Gosu::KbEscape
    end

    def button_down(key)
      @birds[0].flap if key == Gosu::KbSpace
      world.pipe_hole_size += 50 if key == Gosu::KbUp
      world.pipe_hole_size = [0, world.pipe_hole_size - 50].max if key == Gosu::KbDown
      spawn_ai_bird if key == Gosu::KbQ
    end

    def update
      self.update_delta
      # with a delta we need to express the speed of our entities in
      # terms of pixels/second

      @all.each { |group| group.each { |object| object.update(@delta) } }

      @time_to_pipe -= @delta
      spawn_pipe if @time_to_pipe <= 0

      @pipes.delete_if { |pipe| pipe.destroy? }
    end

    def update_delta
      # Gosu::millisecodns returns the time since the window was created
      # Divide by 1000 since we want to work in seconds
      current_time = 0.001 * Gosu::milliseconds
      # clamping here is important to avoid strange behaviors
      @delta = [current_time - @last_milliseconds, 0.25].min
      @last_milliseconds = current_time
    end

    # Object creation
    def spawn_pipe
      hole_height_offset = (rand world.pipe_hole_leeway) - world.pipe_hole_leeway / 2

      @pipes.push RFlappy::GameElements::GameObjectGroup.new(
          RFlappy::GameElements::Pipe.new(hole_height_offset),
          RFlappy::GameElements::Pipe.new(hole_height_offset, :top)
      )

      @time_to_pipe = world.delay_between_pipes
    end

    def spawn_ai_bird
      bird = RFlappy::GameElements::Bird.new
      bird_ai = RFlappy::GameElements::BirdBrain.new bird, @bird_ais.size

      bird.image_alpha = 128

      @birds.push bird
      @bird_ais.push bird_ai
    end
  end

  game = Game.new
  game.show
end
