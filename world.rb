module RFlappy
  class World
    class << self
      # @return [RFlappy::Game]
      attr_accessor :game
      # @return [Fixnum]
      attr_accessor :gravity, :speed, :jump_velocity, :pipe_hole_height
    end

    @gravity = 1000
    @jump_velocity = -500
    @speed = 200
    @pipe_hole_height = 300

    @game = nil
  end
end