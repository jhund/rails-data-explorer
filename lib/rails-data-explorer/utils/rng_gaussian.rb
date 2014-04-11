# From http://stackoverflow.com/a/9266488
class RailsDataExplorer
  module Utils
    class RngGaussian
      def initialize(mean = 0.0, sd = 1.0, rng = lambda { Kernel.rand })
        @mean, @sd, @rng = mean, sd, rng
        @compute_next_pair = false
      end

      def rand
        if (@compute_next_pair = !@compute_next_pair)
          # Compute a pair of random values with normal distribution.
          # See http://en.wikipedia.org/wiki/Box-Muller_transform
          theta = 2 * Math::PI * @rng.call
          scale = @sd * Math.sqrt(-2 * Math.log(1 - @rng.call))
          @g1 = @mean + scale * Math.sin(theta)
          @g0 = @mean + scale * Math.cos(theta)
        else
          @g1
        end
      end
    end
  end
end
