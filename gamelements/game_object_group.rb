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

      def collides?(other_object)
        @objects.inject(false) { |collided, object| collided || object.collides?(other_object) }
      end
    end
  end
end