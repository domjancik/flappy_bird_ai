require 'gosu'
require_relative 'gameobject'
require_relative 'dimensions'
require_relative 'gravity'
require_relative 'velocity'
require_relative 'draw/image'

module RFlappy
  module GameElements
    class Pipe < GameObject
      attr_reader :destroy_flag

      include RFlappy::GameElements::Velocity
      include RFlappy::GameElements::Draw::Image

      def x_spawn
        RFlappy::World.game.width + dims.width_half
      end

      def initialize
        super(RFlappy::GameElements::Dimensions.new(0,0,104,400))
        dims.x = x_spawn

        init_velocity
        init_image('media/pipe.png')

        @destroy_flag = false
      end

      def draw_itself(x, y)
        draw_image(x, y)
      end

      def update(delta)
        update_velocity(delta)
        @x_velocity = -RFlappy::World.speed
      end
    end
  end
end