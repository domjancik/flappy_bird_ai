require_relative 'interval'

module RFlappy
  # Generator
  class Generator
    def self.rand_from_to(from, to)
      interval = to - from
      Random::rand * interval + from
    end

    # @param [RFlappy::Interval] interval
    def self.rand_interval(interval)
      rand_from_to interval.from, interval.to
    end
  end
end
