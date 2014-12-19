require_relative '../interval'
require_relative '../generator'

module RFlappy
  module GameElements
    class BirdBrainParams
      # Settings constants
      TARGET_INTERVAL = Interval.new(0, 864)
      TARGET_THRESHOLD_INTERVAL = Interval.new(0, 200)
      JUMP_DELAY_INTERVAL = Interval.new(0, 2)

      def rand_interval(interval)
        RFlappy::Generator.rand_interval(interval)
      end

      def init_params
        self.height_target = rand_interval(TARGET_INTERVAL) # aim of the bird
        self.target_threshold = rand_interval(TARGET_THRESHOLD_INTERVAL) # distance from target before flapping
        self.jump_delay = rand_interval(JUMP_DELAY_INTERVAL) # min amount of secs to wait before next flap
        # Other possibilities
        # - effect of the next pipe center on the height target
        # - y_velocity effects on the time of flapping

        reset_flap_delay
      end

      def initialize
        @params = {}

        init_params
      end

      # @param [String] name
      # @param [Array] args
      def method_missing(name, *args)
        if /=$/.match(name)
          raise ArgumentError, 'Not the right number of arguments' unless args.size == 1
          strlen = name.size - 2
          @params[name[0..strlen].to_sym] = args[0]
        else
          @params[name.to_sym]
        end
      end
    end
  end
end