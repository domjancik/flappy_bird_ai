module RFlappy
  class World
    class << self
      # @return [RFlappy::Game]
      attr_accessor :game
      # @param [Fixnum]
      # @return [Fixnum]
      attr_accessor :gravity, :speed, :jump_velocity, :pipe_hole_height, :delay_between_pipes
    end

    # World settings, editable realtime
    @gravity = 1000
    @jump_velocity = -500
    @speed = 400
    @pipe_hole_height = 300
    @delay_between_pipes = 4 #in secs

    @game = nil
  end
end