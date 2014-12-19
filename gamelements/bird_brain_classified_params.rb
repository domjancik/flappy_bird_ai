module RFlappy
  module GameElements
    class BirdBrainClassifiedParams
      include Comparable

      attr_reader :params, :fitness

      # @param [RFlappy::GameElements::] params
      # @param [Numeric] fitness
      def initialize(params, fitness)
        @params = params
        @fitness = fitness
      end

      def <=>(other)
        return 1 if other.nil?
        @fitness <=> other.fitness
      end
    end
  end
end