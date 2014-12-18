module RFlappy
  module GameElements
    class GameObject
      # @return [RFlappy::Dimensions]
      attr_reader :dims

      # @param [RFlappy::Dimensions] dimensions
      def initialize(dimensions)
        @dims = dimensions
      end

      # @param [Fixnum] a_min
      # @param [Fixnum] a_max
      # @param [Fixnum] b_min
      # @param [Fixnum] b_max
      def overlaps?(a_min, a_max, b_min, b_max)
        return true if a_max > b_min && a_min < b_max
        false
      end

      # @param [RFlappy::GameElements::GameObject] another_object
      def overlaps_horizontally?(another_object)
        overlaps?(@dims.x_left, @dims.x_right, another_object.dims.x_left, another_object.dims.x_right)
      end

      # @param [RFlappy::GameElements::GameObject] another_object
      def overlaps_vertically?(another_object)
        overlaps?(@dims.y_top, @dims.y_bottom, another_object.dims.y_top, another_object.dims.y_bottom)
      end

      # @param [RFlappy::GameElements::GameObject] another_object
      def collides?(another_object)
        overlaps_horizontally?(another_object) && overlaps_vertically?(another_object)
      end

      def draw_itself(x, y)
        # Needs to be implemented in subclasses to draw anything
      end

      def draw
        draw_itself(dims.x - dims.width_half, dims.y - dims.height_half)
      end
    end
  end
end