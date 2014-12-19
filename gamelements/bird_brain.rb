require_relative 'bird_brain_params'
require_relative 'bird_brain_classified_params'

module RFlappy
  module GameElements
    class BirdBrain
      @@best = nil

      ZERO_PARAMS = RFlappy::GameElements::BirdBrainParams::ZERO

      # @param [RFlappy::GameElements::Bird] bird_to_control
      def initialize(bird_to_control, id)
        @bird = bird_to_control
        @id = id
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

      # Target threshold modified by current distance to pipe
      def actual_target_threshold
        [(@params.target_threshold * distance_to_next_pipe * 0.002), @params.target_threshold].min
        # TODO parametrise the distance multiplier
      end

      def below_target?
        bird_y > @params.height_target + actual_target_threshold
        # TODO threshold has to be affected by speed otherwise it's just moving target
      end

      def should_flap?
        @time_to_flap <= 0 && below_target?
        # TODO target aim, etc.
      end

      def should_iterate_pso?
        @time_to_pso <= 0
      end

      def flap
        @bird.flap
        reset_flap_delay
      end

      def update(delta)
        @time_to_flap -= delta
        @time_to_pso -= delta

        @time_to_flap = [0, @time_to_flap].max
        @time_to_pso = [0, @time_to_pso].max

        flap if should_flap?
        iterate_pso if should_iterate_pso?

        update_best!
      end

      def draw
        # TODO draw lines representing target, threshold, etc.
        font.draw(@id.to_s, @bird.dims.x - 70, @bird.dims.y, 0)
        target_line_x = @bird.dims.x + 50 * (@id + 1)
        game.draw_line(@bird.dims.x + 30, @bird.dims.y, Gosu::Color::WHITE, target_line_x, @params.height_target, Gosu::Color::RED)
        game.draw_line(target_line_x, @params.height_target, Gosu::Color::RED, target_line_x + 50, @params.height_target, Gosu::Color::RED)

        game.draw_line(target_line_x, @params.height_target, Gosu::Color::WHITE, target_line_x, @params.height_target + @params.target_threshold, Gosu::Color::WHITE)
        game.draw_line(target_line_x, @params.height_target, Gosu::Color::BLACK, target_line_x, @params.height_target + actual_target_threshold, Gosu::Color::BLACK)

        game.draw_line(target_line_x, @params.height_target + 10, Gosu::Color::WHITE, target_line_x + @params.jump_delay * 20, @params.height_target + 10, Gosu::Color::WHITE)
        game.draw_line(target_line_x, @params.height_target + 10, Gosu::Color::BLACK, target_line_x + @time_to_flap * 20, @params.height_target + 10, Gosu::Color::BLACK)
      end

      def fitness
        #@bird.distance
        return 0 if @bird.score < 2

        @bird.score + @bird.distance * 0.0001
      end

      # @return [RFlappy::GameElements::BirdBrainClassifiedParams]
      def classified_params
        RFlappy::GameElements::BirdBrainClassifiedParams.new(@params.clone, fitness)
      end

      def relative_fitness
        return 0.5 if game.total_fitness == 0
        fitness.to_f / game.total_fitness.to_f
      end

      def best_fitness?
        game.bird_ais.inject(true) { |val, bird_ai| val && fitness >= bird_ai.fitness }
      end

      def update_best!
        cur_params = classified_params

        @best = cur_params if cur_params > @best

        return if fitness <= 0
        @@best = @best if @best > @@best
      end

      def transparency
        return 255 if best_fitness?
        relative_fitness * 255 * 2
      end

      def update_transparency
        @bird.image_alpha = transparency
      end

      def iterate_pso
        alpha = RFlappy::RandomHelper.rand_interval(RFlappy::Interval::ZERO_ONE)
        beta = RFlappy::RandomHelper.rand_interval(RFlappy::Interval::ZERO_ONE)

        inertia_part = @velocity * world.pso_inertia
        local_best_part = @best.nil? ? ZERO_PARAMS : (@best.params - @params) * alpha * world.pso_local_best_influence
        global_best_part = @@best.nil? ? ZERO_PARAMS : (@@best.params - @params) * beta * world.pso_global_best_influence

        @velocity = inertia_part + local_best_part + global_best_part

        @params += @velocity

        update_best!
        reset_pso_delay
        update_transparency
      end

      def distance_to_next_pipe
        min_dist_to_pipe = Float::INFINITY
        game.pipes.each do |pipe|
          min_dist_to_pipe = [min_dist_to_pipe, pipe.dims.x - @bird.dims.x].min if pipe.dims.x > @bird.dims.x
        end

        min_dist_to_pipe
      end

      def world
        RFlappy::World
      end

      # @return [Gosu::Font]
      def font
        game.font
      end

      # @return [RFlappy::Game]
      def game
        RFlappy::World.game
      end
    end
  end
end