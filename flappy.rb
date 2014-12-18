require 'rubygems'
require 'gosu'

# Own classes
require_relative 'gamelements/bird'
require_relative 'gamelements/pipe'
require_relative 'gamelements/game_object_group'

module RFlappy
  class Game < Gosu::Window
    attr_reader :width, :height, :pipes

    def initialize
      @width, @height = 1280, 864

      super(@width, @height, false)
      self.caption = 'Flappy Bird AI'

      RFlappy::World.game = self

      @background = Gosu::Image.new(self, 'media/bg.png')

      @birds = [ RFlappy::GameElements::Bird.new ]
      @pipes = []
      spawn_pipe

      @all = [ @birds, @pipes ]

      @last_milliseconds = 0
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
      @birds[0].jump if key == Gosu::KbSpace
    end


    def update
      self.update_delta
      # with a delta we need to express the speed of our entities in
      # terms of pixels/second

      @all.each { | group | group.each { | object | object.update(@delta) } }
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
      @pipes.push RFlappy::GameElements::GameObjectGroup.new(
          RFlappy::GameElements::Pipe.new,
          RFlappy::GameElements::Pipe.new(:top)
      )
    end
  end

  game = Game.new
  game.show
end
