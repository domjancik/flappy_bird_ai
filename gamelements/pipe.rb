require 'gosu'
require_relative 'game_object'
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
        game.width + dims.width_half
      end

      def y_spawn(hole_height_offset, variant)
        center_offset = world.pipe_hole_size / 2 + dims.height / 2
        center = game.height * 0.5 + hole_height_offset
        variant == :bottom ? center + center_offset : center - center_offset
      end

      # @param [Fixnum] hole_height_offset
      # @param [Symbol] variant :top or :bottom
      def initialize(hole_height_offset, variant = :bottom)
        super(RFlappy::GameElements::Dimensions.new(0,0,104,800))
        dims.x = x_spawn

        dims.y = y_spawn(hole_height_offset, variant)

        init_velocity
        init_image('media/pipe.png')

        @rotation = variant == :bottom ? 0 : 180
      end

      def draw_itself(x, y)
        draw_image(x, y, @rotation)
      end

      def update(delta)
        update_velocity(delta)
        @x_velocity = -world.speed
        @destroy_flag = true if dims.x < 0 - dims.width_half
      end
    end
  end
end