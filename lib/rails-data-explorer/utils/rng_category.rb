class RailsDataExplorer
  module Utils
    class RngCategory

      def initialize(categories, category_probabilities = nil, rng = lambda { Kernel.rand })
        @categories, @category_probabilities, @rng = categories, category_probabilities, rng
        @category_probabilities ||= @categories.map { |e| @rng.call }
        @category_probabilities = normalize_category_probabilities
        @category_order = compute_category_order
      end

      def rand
        r_v = @rng.call
        rnd = @category_order.detect { |e|
          e[:threshold] >= r_v
        }
        rnd[:category]
      end

      def normalize_category_probabilities
        total = @category_probabilities.inject(0) { |m,e| m += e }
        @category_probabilities.map { |e| e / total.to_f }
      end

      def compute_category_order
        category_order = []
        running_sum = 0
        @categories.each_with_index { |e, idx|
          running_sum += @category_probabilities[idx]
          category_order << { :category => e, :threshold => running_sum }
        }
        category_order
      end

    end
  end
end
