module RFlappy
  class World
    class << self
      attr_accessor :gravity, :speed, :window, :jump_velocity
    end

    @gravity = 1000
    @jump_velocity = -500
    @speed = 2
    @window = nil
  end
end