require_relative '../interval'
require_relative '../generator'

module RFlappy
  module GameElements
    class BirdBrain
      # Settings constants
      TARGET_INTERVAL = Interval.new(0, 864)
      TARGET_THRESHOLD_INTERVAL = Interval.new(0, 200)
      JUMP_DELAY_INTERVAL = Interval.new(0, 2)

      # @param [RFlappy::GameElements::Bird] bird_to_control
      def initialize(bird_to_control)
        @bird = bird_to_control

        init_params
      end


      def rand_interval(interval)
        RFlappy::Generator.rand_interval(interval)
      end

      def init_params
        @height_target = rand_interval(TARGET_INTERVAL) # aim of the bird
        @target_threshold = rand_interval(TARGET_THRESHOLD_INTERVAL) # distance from target before flapping
        @jump_delay = rand_interval(JUMP_DELAY_INTERVAL) # min amount of secs to wait before next flap
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

      def below_target?
        bird_y > @height_target + @target_threshold
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