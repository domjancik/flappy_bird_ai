require_relative 'interval'
require_relative 'world'

module RFlappy
  # Generator
  class RandomHelper
    def self.rand_from_to(from, to)
      interval = to - from
      Random::rand * interval + from
    end

    # @param [RFlappy::Interval] interval
    def self.rand_interval(interval)
      rand_from_to interval.from, interval.to
    end

    def self.rand_screen_height
      rand_from_to 0, RFlappy::World.game.height
    end
  end
end
