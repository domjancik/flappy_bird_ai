module RFlappy
  module GameElements
    # Compound objects, little bit of duck typing ;)
    class GameObjectGroup
      def initialize(*objects)
        @objects = objects
      end

      def draw
        @objects.each { |object| object.draw }
      end

      def update(delta)
        @objects.each { |object| object.update(delta) }
      end

      # @param [RFlappy::GameElements::GameObject] other_object
      def collides?(other_object)
        @objects.inject(false) { |collided, object| collided || object.collides?(other_object) }
      end

      # @param [RFlappy::GameElements::GameObject] other_object
      def overlaps_horizontally?(other_object)
        @objects.inject(false) { |collided, object| collided || object.overlaps_horizontally?(other_object) }
      end

      def destroy?
        @objects.inject(true) { |destroy, object| destroy && object.destroy? }
      end
    end
  end
end