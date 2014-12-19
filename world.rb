module RFlappy
  class World
    class << self
      # @return [RFlappy::Game]
      attr_accessor :game
      # @param [Fixnum]
      # @return [Fixnum]
      attr_accessor :gravity, :speed, :flap_velocity, :pipe_hole_size, :delay_between_pipes, :pipe_hole_leeway
    end

    # World settings, editable realtime
    @gravity = 1000
    @flap_velocity = -500
    @speed = 400
    @pipe_hole_size = 300
    @pipe_hole_leeway = 0#400
    @delay_between_pipes = 1 #in secs

    @game = nil
  end
end