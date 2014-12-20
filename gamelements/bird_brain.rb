require_relative 'bird_brain_params'
require_relative 'bird_brain_classified_params'

module RFlappy
  module GameElements
    class BirdBrain
      attr_reader :params

      class << self
        def best
          @@best
        end

        def reset_global_best
          @@best = nil
        end
      end

      @@best = nil

      def best_live_ai
        game.bird_ais.inject(self) do |known_best, bird_ai|
          bird_ai.fitness > known_best.fitness ? bird_ai : known_best
        end
      end

      def best_live_params
        best_live_ai.params
      end

      ZERO_PARAMS = RFlappy::GameElements::BirdBrainParams::ZERO

      # @param [RFlappy::GameElements::Bird] bird_to_control
      def initialize(bird_to_control, id)
        @bird = bird_to_control
        @bird.on_die = lambda { mutate_params }
        @id = id
        @best = nil

        @params = RFlappy::GameElements::BirdBrainParams.new(:random)
        @velocity = RFlappy::GameElements::BirdBrainParams.new(:zero)

        @target_height = 300

        reset_flap_delay
        reset_pso_delay
      end

      def mutate_params
        @params.mutate
        @params.validate
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
        [(@params.target_threshold * distance_to_next_pipe * @params.dist_thresh_mult), @params.target_threshold].min
      end

      def target_height
        @target_height
      end

      def update_target!
        pipe = next_pipe
        fin_target = pipe.nil? ? 400 + @params.target_offset : next_pipe.y_center + @params.target_offset
        @target_height = @target_height * (1 - @params.retarget_speed) + fin_target * @params.retarget_speed
      end

      def below_target?
        bird_y > target_height + actual_target_threshold
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
        update_target!
      end

      def actual_target_height
        target_height + actual_target_threshold
      end

      def draw
        # TODO draw lines representing target, threshold, etc.
        font.draw(@id.to_s, @bird.dims.x - 70, @bird.dims.y, 0)
        target_line_x = @bird.dims.x + 50 * (@id + 1)

        color = best_fitness? ? Gosu::Color::YELLOW : Gosu::Color::RED

        game.draw_line(@bird.dims.x + 30, @bird.dims.y, Gosu::Color::WHITE, target_line_x, target_height, color)
        game.draw_line(target_line_x, target_height, color, target_line_x + 50, target_height, color)
        game.draw_line(target_line_x, actual_target_height, color, target_line_x + 25, actual_target_height, color)

        game.draw_line(target_line_x, target_height, Gosu::Color::WHITE, target_line_x, target_height + @params.target_threshold, Gosu::Color::WHITE)
        game.draw_line(target_line_x, target_height, Gosu::Color::BLACK, target_line_x, actual_target_height, Gosu::Color::BLACK)

        game.draw_line(target_line_x, target_height + 10, Gosu::Color::WHITE, target_line_x + @params.jump_delay * 20, target_height + 10, Gosu::Color::WHITE)
        game.draw_line(target_line_x, target_height + 10, Gosu::Color::BLACK, target_line_x + @time_to_flap * 20, target_height + 10, Gosu::Color::BLACK)
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
        gamma = RFlappy::RandomHelper.rand_interval(RFlappy::Interval::ZERO_ONE)

        inertia_part = @velocity * world.pso_inertia
        local_best_part = @best.nil? ? ZERO_PARAMS : (@best.params - @params) * alpha * world.pso_local_best_influence
        global_best_part = @@best.nil? ? ZERO_PARAMS : (@@best.params - @params) * beta * world.pso_global_best_influence
        live_best_part = (best_live_params - @params) * gamma * world.pso_live_best_influence

        @velocity = inertia_part + local_best_part + global_best_part + live_best_part

        @params += @velocity
        @params.validate

        update_best!
        reset_pso_delay
        update_transparency
      end

      def dist_to_pipe(pipe)
        pipe.nil? ? 0 : pipe.dims.x - @bird.dims.x
      end

      def next_pipe
        min_dist_to_pipe = Float::INFINITY
        pipe_with_min_dist = nil
        game.pipes.each do |pipe|
          pipe_dist = dist_to_pipe pipe
          if pipe.dims.x > @bird.dims.x && pipe_dist < min_dist_to_pipe && pipe_dist > 0
            min_dist_to_pipe = pipe_dist
            pipe_with_min_dist = pipe
          end
        end

        pipe_with_min_dist
      end

      def distance_to_next_pipe
        dist_to_pipe(next_pipe).abs
      end

      def randomize
        @best = nil
        @params.init_random_params
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