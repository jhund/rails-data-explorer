# -*- coding: utf-8 -*-

class RailsDataExplorer
  module Utils

    # Responsibilities:
    #  * Convert quantitative data to categorical data.
    #
    # http://saedsayad.com/binning.htm
    # E.g., ages in years to 5 groups:
    # * < 10
    # * 11 - 20
    # * 21 - 30
    # * 31 - 40
    # * > 40
    class DataBinner

      # @param[Hash] threshold_specs a hash with a key value pair for each threshold
      #   The key is the label to use, and the value is a Numeric threshold.
      #   Adds one more bin for values greater than the highest threshold.
      #   Example: { '0' => 0, '1' => 1, '2' => 2, '3..10' => 10, '11..100' => 100 }
      #   Will generate the following output:
      #     -1   => '0'
      #      0   => '0'
      #      0.1 => '1'
      #      4   => '3..10'
      #     10   => '3..10'
      #     10.1 => '3..10'
      #   1000   => '> 100'
      def initialize(threshold_specs)
        @max = -Float::INFINITY
        @bin_specs = threshold_specs.to_a.sort { |(k_a, v_a), (k_b, v_b)|
          v_a <=> v_b
        }.map { |(label, threshold)|
          raise "Invalid threshold: #{ threshold.inspect }"  unless threshold.is_a?(Numeric)
          @max = [@max, threshold].max
          { label: label, lte: threshold }
        }
        @bin_specs << { label: "> #{ @max }", gt: @max }
      end

      def bin(value)
        unless value.is_a?(Numeric)
          raise(ArgumentError.new("Wrong type of value, numeric expected, got: #{ value.inspect }"))
        end
        bin = @bin_specs.detect { |bs|
          (bs[:lte] && value <= bs[:lte]) || (bs[:gt] && value > bs[:gt])
        }
        bin[:label]
      end

    end
  end
end
