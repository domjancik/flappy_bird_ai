require 'gosu'
require_relative 'gameobject'
require_relative 'dimensions'
require_relative 'gravity'
require_relative 'velocity'
require_relative 'draw/image'

module RFlappy
  module GameElements
    class Bird < GameObject
      include RFlappy::GameElements::Velocity
      include RFlappy::GameElements::Gravity
      include RFlappy::GameElements::Draw::Image

      def initialize
        super(RFlappy::GameElements::Dimensions.new(100,0,68,48))

        init_velocity
        init_gravity
        init_image('media/bird.png')
      end

      def rotation_angle
        rot_angle = @y_velocity * 0.08
        [ [ rot_angle, 90 ].min, -90 ].max
      end

      def jump
        @y_velocity = RFlappy::World.jump_velocity
      end

      def draw_itself(x, y)
        draw_image(x, y, rotation_angle)
      end

      def update(delta)
        update_gravity(delta)
        update_velocity(delta)
        collide_with_pipes
      end

      def collide_with_pipes
        RFlappy::World.game.pipes.each { |pipe| die if pipe.collides?(self) }
      end

      def die
        reset_score
        respawn
      end

      def reset_score
        @score = 0
      end

      def respawn
        @y_velocity, @dims.y = 0, 0
      end
    end
  end
end