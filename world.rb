module RFlappy
  # Global settings as class attributes
  class World
    class << self
      # @return [RFlappy::Game]
      attr_accessor :game
      # @param [Fixnum]
      # @return [Fixnum]
      attr_accessor :gravity, :speed, :flap_velocity, :pipe_hole_size, :delay_between_pipes, :pipe_hole_leeway,
                    :delay_between_pso, :pso_inertia, :pso_local_best_influence, :pso_global_best_influence
    end

    # World settings, editable realtime
    @gravity = 1000
    @flap_velocity = -500
    @speed = 400
    @pipe_hole_size = 300
    @pipe_hole_leeway = 400
    @delay_between_pipes = 1 #in secs

    @delay_between_pso = 0.25 #in secs
    @pso_inertia = 0.5
    @pso_local_best_influence = 0.25
    @pso_global_best_influence = 0.25

    @game = nil
  end
end