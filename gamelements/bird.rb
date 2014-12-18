require 'gosu'
require_relative 'gameobject'
require_relative 'dimensions'
require_relative 'gravity'
require_relative 'velocity'

module RFlappy
  module GameElements
    class Bird < GameObject
      include RFlappy::GameElements::Velocity
      include RFlappy::GameElements::Gravity

      def initialize
        @image = Gosu::Image.new(RFlappy::World.window, 'media/bird.png')
        super(RFlappy::GameElements::Dimensions.new(100,0,50,50));

        init_velocity
        init_gravity
      end

      def rotation_angle
        rot_angle = @y_velocity * 0.08
        [ [ rot_angle, 90 ].min, -90 ].max
      end

      def draw_image(x, y)
        RFlappy::World.window.rotate(rotation_angle, @dims.x, @dims.y) {
          @image.draw(x, y, 0);
        }
      end

      def jump
        @y_velocity = RFlappy::World.jump_velocity
      end

      def update(delta)
        update_gravity(delta)
        update_velocity(delta)
      end
    end
  end
end