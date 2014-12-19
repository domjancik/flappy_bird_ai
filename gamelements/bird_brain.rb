module RFlappy
  module GameElements
    class BirdBrain
      # @param [RFlappy::GameElements::Bird] bird_to_control
      def initialize(bird_to_control)
        @bird = bird_to_control

        init_params
      end

      def init_params
        @height_target = 200 # aim of the bird
        @jump_threshold = 50 # distance from target before flapping
        @jump_delay = 0.5 # min amount of secs to wait before next flap
        # Other possibilities
        # - effect of the next pipe center on the height target
        # - y_velocity effects on the time of flapping

        reset_flap_delay
      end

      def reset_flap_delay
        @time_to_flap = @jump_delay
      end

      def bird_y
        @bird.dims.y
      end

      def should_flap?
        @time_to_flap < 0
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