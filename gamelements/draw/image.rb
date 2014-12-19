require_relative '../../world'
require 'gosu'

module RFlappy
  module GameElements
    module Draw
      # Adds drawing capabilities to GameObjects
      module Image
        def init_image(image_path)
          @image = Gosu::Image.new(RFlappy::World.game, image_path)
          @image_color = Gosu::Color::WHITE
        end

        def draw_image(x, y, rotation = 0, scale = 1)
          RFlappy::World.game.rotate(rotation, @dims.x, @dims.y) {
            @image.draw(x, y, 0, 1, 1, @image_color);
          }
        end

        def image_alpha=(alpha)
          @image_color = Gosu::Color.new(alpha, @image_color.red, @image_color.green, @image_color.blue)
        end
      end
    end
  end
end
