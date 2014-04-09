module Utils
  class RngPowerLaw

    def initialize(min = 1, max = 1000, pow = 2, rng = lambda { Kernel.rand })
      @min, @max, @pow, @rng = min, max, pow, rng
      @max += 1
    end

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
