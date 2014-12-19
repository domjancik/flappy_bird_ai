require_relative 'bird_brain_params'

module RFlappy
  module GameElements
    class BirdBrain
      # @param [RFlappy::GameElements::Bird] bird_to_control
      def initialize(bird_to_control)
        @bird = bird_to_control

        @params = RFlappy::GameElements::BirdBrainParams.new
        reset_flap_delay
      end

      def reset_flap_delay
        @time_to_flap = @params.jump_delay
      end

      def bird_y
        @bird.dims.y
      end

      def below_target?
        bird_y > @params.height_target + @params.target_threshold
        # TODO threshold has to be affected by speed otherwise it's just moving target
      end

      def should_flap?
        @time_to_flap < 0 && below_target?
        # TODO target aim, etc.
      end

      def flap
        @bird.flap
        reset_flap_delay
      end

      def update(delta)
        @time_to_flap -= delta

        flap if should_flap?
      end

      def draw
        # TODO draw lines representing target, threshold, etc.
      end
    end
  end
end