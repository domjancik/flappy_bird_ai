require_relative '../world'

module RFlappy
  module GameElements
    # Can be used to add gravity effects to objects with Velocity
    module Gravity
      def init_gravity

      end

      def update_gravity(delta)
        @y_velocity += World.gravity * delta
      end
    end
  end
end