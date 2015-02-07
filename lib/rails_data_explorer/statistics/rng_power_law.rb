# -*- coding: utf-8 -*-

class RailsDataExplorer
  module Statistics

    # Responsibilities:
    #  * Provide random numeric data, following a power distribution.
    #
    class RngPowerLaw

      # @param min [Numeric]
      # @param max [Numeric]
      # @param pow [Numeric]
      # @param rng [Proc, optional] a random number generator
      def initialize(min = 1, max = 1000, pow = 2, rng = lambda { Kernel.rand })
        @min, @max, @pow, @rng = min, max, pow, rng
        @max += 1
      end

      # Returns random data following a power distribution.
      def rand
        y = (
          (
            (@max ** (@pow + 1) - @min ** (@pow + 1)) * @rng.call + @min ** (@pow + 1)
          ) ** (1.0 / (@pow + 1))
        ).to_i
        (@max - 1 - y) + @min
      end

    end
  end
end
