module RFlappy
  class Interval
    attr_reader :from, :to

    # @param [Fixnum] from
    # @param [Fixnum] to
    def initialize(from, to)
      @from = from
      @to = to
    end

    def limit(val)
      [[val, from].max, to].min
    end

    ZERO_ONE = RFlappy::Interval.new(0, 1)
  end
end