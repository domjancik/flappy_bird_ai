require_relative 'bird_brain_params'
require_relative 'bird_brain_classified_params'

module RFlappy
  module GameElements
    class BirdBrain
      @@best = nil

      # @param [RFlappy::GameElements::Bird] bird_to_control
      def initialize(bird_to_control)
        @bird = bird_to_control
        @best = nil

        @params = RFlappy::GameElements::BirdBrainParams.new(:random)
        @velocity = RFlappy::GameElements::BirdBrainParams.new(:zero)

        reset_flap_delay
        reset_pso_delay
      end

      def reset_flap_delay
        @time_to_flap = @params.jump_delay
      end
      
      def reset_pso_delay
        @time_to_pso = RFlappy::World.delay_between_pso
      end

      def bird_y
        @bird.dims.y
      end

      def below_target?
        bird_y > @params.height_target + @params.target_threshold
        # TODO threshold has to be affected by speed otherwise it's just moving target
      end

      def should_flap?
        @time_to_flap < 0 && below_target?
        # TODO target aim, etc.
      end

      def should_iterate_pso?
        @time_to_pso < 0
      end

      def flap
        @bird.flap
        reset_flap_delay
      end

      def update(delta)
        @time_to_flap -= delta
        @time_to_pso -= delta

        flap if should_flap?
        iterate_pso if should_iterate_pso?

        update_best!
      end

      def draw
        # TODO draw lines representing target, threshold, etc.
      end

      def fitness
        @bird.distance
      end

      # @return [RFlappy::GameElements::BirdBrainClassifiedParams]
      def classified_params
        RFlappy::GameElements::BirdBrainClassifiedParams.new(@params.clone, fitness)
      end

      def update_best!
        cur_params = classified_params
        @best = cur_params if cur_params > @best
        @@best = @best if @best > @@best
      end

      def iterate_pso
        alpha = RFlappy::Generator.rand_interval(RFlappy::Interval::ZERO_ONE)
        beta = RFlappy::Generator.rand_interval(RFlappy::Interval::ZERO_ONE)

        inertia_part = @velocity * world.pso_inertia
        local_best_part = @best.nil? ? 0 : @best.params - @params * alpha * world.pso_local_best_influence
        global_best_part = @@best.nil? ? 0 : @@best.params - @params * beta * world.pso_global_best_influence

        @velocity = inertia_part + local_best_part + global_best_part

        @params += @velocity

        update_best!
        reset_pso_delay
      end

      def world
        RFlappy::World
      end
    end
  end
end