module RFlappy
  class Interval
    attr_reader :from, :to

    # @param [Fixnum] from
    # @param [Fixnum] to
    def initialize(from, to)
      @from = from
      @to = to
    end
  end
end