module RFlappy
  module GameElements
    class Dimensions
      # @return [Fixnum]
      # @return [Fixnum]
      attr_accessor :x, :y
      # @return [Fixnum]
      # @return [Fixnum]
      # @return [Fixnum]
      # @return [Fixnum]
      attr_reader :width, :height, :width_half, :height_half

      # @param [Fixnum] x
      # @param [Fixnum] y
      # @param [Fixnum] width
      # @param [Fixnum] height
      def initialize(x, y, width, height)
        @x, @y, @width, @height = x, y, width, height
        @width_half = width / 2
        @height_half = height / 2
      end

      # @param [Fixnum] width
      # @return [Fixnum]
      def width=(width)
        @width = width
        @width_half = @width / 2
      end

      # @param [Fixnum] height
      # @return [Fixnum]
      def height=(height)
        @height = height
        @height_half = @height / 2
      end

      # @return [Fixnum]
      def x_left
        @x - @width_half
      end

      # @return [Fixnum]
      def x_right
        @x + @width_half
      end

      # @return [Fixnum]
      def y_top
        @y - @height_half
      end

      # @return [Fixnum]
      def y_bottom
        @y + @height_half
      end
    end
  end
end