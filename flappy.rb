require 'rubygems'
require 'gosu'

# Own classes
require_relative 'gamelements/bird'
require_relative 'gamelements/bird_brain'
require_relative 'gamelements/pipe'
require_relative 'gamelements/game_object_group'

module RFlappy
  class Game < Gosu::Window
    attr_reader :width, :height, :pipes, :font, :total_fitness, :bird_ais

    TEXT_COLOR = Gosu::Color::WHITE
    TEXT_SELECTED_COLOR = Gosu::Color::YELLOW
    TEXT_BG_COLOR = Gosu::Color.new(128, 0, 0, 0)

    WORLD_PARAMS = [
        ['gravity' , 'Gravity', {:lo => 1, :hi => 50}],
        ['flap_velocity' , 'Flap Velocity', {:lo => 1, :hi => 50}],
        ['speed' , 'Speed', {:lo => 1, :hi => 50}],
        ['pipe_hole_size' , 'Pipe Hole Size', {:lo => 1, :hi => 50}],
        ['pipe_hole_leeway' , 'Pipe Leeway', {:lo => 1, :hi => 50}],
        ['delay_between_pipes' , 'Pipe Delay', {:lo => 0.1, :hi => 1}],
        ['delay_between_pso' , 'PSO Delay', {:lo => 0.01, :hi => 0.1}],
        ['pso_inertia' , 'PSO Inertia', {:lo => 0.01, :hi => 0.25}],
        ['pso_local_best_influence' , 'PSO loc. infl', {:lo => 0.01, :hi => 0.25}],
        ['pso_global_best_influence' , 'PSO glob. infl', {:lo => 0.01, :hi => 0.25}],
        ['pso_live_best_influence' , 'PSO live best infl', {:lo => 0.01, :hi => 0.25}],
        ['mutation_on_death' , 'Death mutation', {:lo => 0.01, :hi => 0.1}]
    ]

    def get_world_param(name)
      world.send name
    end

    def set_world_param(name, val)
      world.send (name + '='), val
    end

    def world
      RFlappy::World
    end

    def initialize
      @width, @height = 1280, 864

      super(@width, @height, false)
      self.caption = 'Flappy Bird AI'

      world.game = self

      @background = Gosu::Image.new(self, 'media/bg.png')

      @birds = []#[ RFlappy::GameElements::Bird.new ]
      @bird_ais = []
      @pipes = []
      @all = [ @birds, @pipes, @bird_ais ]
      @time_to_pipe = 0

      @last_milliseconds = 0

      @max_score = 0
      @total_fitness = 0

      @font = Gosu::Font.new(self, 'Arial', 20)
      @selected_param = 0

      (0..20).each { spawn_ai_bird }
    end

    def select_next_param
      @selected_param = (@selected_param + 1) % WORLD_PARAMS.size
    end

    def select_previous_param
      @selected_param = @selected_param > 0 ? (@selected_param - 1) : WORLD_PARAMS.size - 1
    end

    def selected_param_id
      WORLD_PARAMS[@selected_param][0]
    end

    def modify_selected_param(by)
      id = selected_param_id
      set_world_param(id, get_world_param(id) + by)
    end

# @param [Symbol] how_much :lo or :hi
# @param [Symbol] direction :add or :sub
    def edit_selected_param(how_much, direction)
      amount = WORLD_PARAMS[@selected_param][2][how_much]
      direction == :add ? modify_selected_param(amount) : modify_selected_param(-amount)
    end

    def add_selected_param(how_much)
      edit_selected_param how_much, :add
    end

    def subtract_selected_param(how_much)
      edit_selected_param how_much, :subtract
    end

    def draw_rectangle(ax, ay, bx, by, color)
      draw_quad(ax, ay, color, bx, ay, color, bx, by, color, ax, by, color)
    end

    def draw
      @background.draw(0, 0, 0)

      @all.each { | group | group.each { | object | object.draw } }

      # Info
      font.draw('Max score ' + @max_score.to_s, 10, 10, 0)

      param_idx = 0
      WORLD_PARAMS.each_index do |id|
        x = 10 + 200 * (param_idx % 6)
        line = (param_idx / 6)
        y = height - 80 + 30 * line

        color = @selected_param == id ? TEXT_SELECTED_COLOR : TEXT_COLOR
        param_name = WORLD_PARAMS[id][1]
        param_id = WORLD_PARAMS[id][0]
        draw_rectangle(x - 5, y - 5, x + 190, y + 23, TEXT_BG_COLOR)
        font.draw(param_name + ': ' + get_world_param(param_id).to_s, x, y, 0, 1, 1, color)
        param_idx += 1
      end
    end

    # this is a callback for key up events or equivalent (there are
    # constants for gamepad buttons and mouse clicks)
    def button_up(key)
      self.close if key == Gosu::KbEscape
    end

    def button_down(key)
      @birds[0].flap if key == Gosu::KbSpace

      add_selected_param(:lo) if key == Gosu::KbUp
      add_selected_param(:hi) if key == Gosu::KbPageUp

      subtract_selected_param(:lo) if key == Gosu::KbDown
      subtract_selected_param(:hi) if key == Gosu::KbPageDown

      select_next_param if key == Gosu::KbRight
      select_previous_param if key == Gosu::KbLeft

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

      @max_score = @birds.inject(0) { |val, bird| [val, bird.score].max }
      @total_fitness = @bird_ais.inject(0) { |val, bird_ai| val + bird_ai.fitness }
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
