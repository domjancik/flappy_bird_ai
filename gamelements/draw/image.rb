require_relative '../../world'

module RFlappy
  module GameElements
    module Draw
      # Adds drawing capabilities to GameObjects
      module Image
        def init_image(image_path)
          @image = Gosu::Image.new(RFlappy::World.window, image_path)
        end

        def draw_image(x, y)
          RFlappy::World.window.rotate(rotation_angle, @dims.x, @dims.y) {
            @image.draw(x, y, 0);
          }
        end
      end
    end
  end
end
