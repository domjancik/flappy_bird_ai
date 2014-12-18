module RFlappy
  module GameElements
    # Can be used to add velocity support to any object with dims that contains a Dimensions object
    module Velocity
      attr_accessor :x_velocity, :y_velocity

      def init_velocity
        @x_velocity = 0
        @y_velocity = 0
      end

      def update_velocity(delta)
        dims.x += @x_velocity * delta
        dims.y += @y_velocity * delta
      end
    end
  end
end