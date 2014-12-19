require 'gosu'
require_relative 'game_object'
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

      attr_reader :distance, :score

      def initialize
        super(RFlappy::GameElements::Dimensions.new(100,0,68,48))
        die

        init_velocity
        init_gravity
        init_image('media/bird.png')
      end

      def rotation_angle
        rot_angle = @y_velocity * 0.08
        [ [ rot_angle, 90 ].min, -90 ].max
      end

      def flap
        @y_velocity = RFlappy::World.flap_velocity
      end

      def draw_itself(x, y)
        draw_image(x, y, rotation_angle)
      end

      def update(delta)
        update_gravity(delta)

        @score += 1 if @in_pipes_before_movement && !in_pipes?
        @in_pipes_before_movement = in_pipes?

        update_velocity(delta)

        @distance += world.speed * delta

        collide_with_pipes
      end

      def in_pipes?
        game.pipes.inject(false) { |collided, pipe| collided || pipe.overlaps_horizontally?(self) }
      end

      def collide_with_pipes
        game.pipes.each { |pipe| die if pipe.collides?(self) }
      end

      def die
        reset_score
        respawn
      end

      def reset_score
        @distance = 0
        @score = 0
        @in_pipes_before_movement = false
      end

      def respawn
        @y_velocity, @dims.y = 0, 300
      end
    end
  end
end