require_relative '../interval'
require_relative '../generatora'

module RFlappy
  module GameElements
    class BirdBrainParams
      attr_reader :params

      # Settings constants
      TARGET_INTERVAL = Interval.new(0, 864)
      TARGET_THRESHOLD_INTERVAL = Interval.new(0, 200)
      JUMP_DELAY_INTERVAL = Interval.new(0, 2)

      def rand_interval(interval)
        RFlappy::RandomHelper.rand_interval(interval)
      end

      def init_random_params
        self.height_target = rand_interval(TARGET_INTERVAL) # aim of the bird
        self.target_threshold = rand_interval(TARGET_THRESHOLD_INTERVAL) # distance from target before flapping
        self.jump_delay = rand_interval(JUMP_DELAY_INTERVAL) # min amount of secs to wait before next flap
        # Other possibilities
        # - effect of the next pipe center on the height target
        # - y_velocity effects on the time of flapping
      end

      def init_zero_params
        self.height_target = 0
        self.target_threshold = 0
        self.jump_delay = 0
      end

      # @param [Symbol] init_method :random, :zero or :supplied
      def initialize(init_method = :random, supplied_params = {})
        @params = supplied_params

        init_random_params if init_method == :random
        init_zero_params if init_method == :zero
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

      # @param [RFlappy::GameElements::BirdBrainParams] other
      def +(add)
        param_operation { |key, val| val + add.params[key] }
      end

      # @param [RFlappy::GameElements::BirdBrainParams] other
      def -(subtract)
        param_operation { |key, val| val - subtract.params[key] }
      end

      # @param [Numeric] multiplier
      def *(multiplier)
        param_operation { |key, val| val * multiplier }
      end

      def param_operation
        raise ArgumentError, 'A block is required' unless block_given?

        modified_params = {}
        @params.each_pair do |param_name, param_value|
          modified_params[param_name] = yield param_name, param_value
        end

        RFlappy::GameElements::BirdBrainParams.new(:supplied, modified_params)
      end
    end
  end
end