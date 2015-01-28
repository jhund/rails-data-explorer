# Map a large set of quantitative/temporal/geo input values to a (countable)
# smaller set – such as rounding values to some unit of precision.
class RailsDataExplorer
  module Utils
    class DataQuantizer

      attr_accessor :number_of_bins, :delta

      def initialize(data_series, options = {})
        @options = {
          nice: true,
          type: 'midtread', # 'midtread' or 'midrise'
          number_of_bins: 100, # assuming 800px wide chart, 8px per bin
          delta: nil,
        }.merge(options)
        @data_series = data_series
        @number_of_bins = @options[:number_of_bins]
        init_attrs
      end

      def init_attrs
        # Compute boundaries
        if @options[:nice]
          range = @data_series.max_val - @data_series.min_val
          rounding_factor = 10.0 ** Math.log10([range, GREATER_ZERO].max).floor
          @min_val = (@data_series.min_val / rounding_factor).floor * rounding_factor
          @max_val = (@data_series.max_val / rounding_factor).ceil * rounding_factor
        else
          @min_val = @data_series.min_val
          @max_val = @data_series.max_val
        end
        # Compute delta
        @delta = if @options[:delta]
          @options[:delta]
        else
          (@max_val - @min_val) / @number_of_bins.to_f
        end
      end

      def values
        @values ||= (
          case @options[:type]
          when 'midrise'
            @data_series.values.map { |e|
              index_of_quantized_value = ((e - @min_val) / @delta).round
              (
                (index_of_quantized_value * @delta) +
                (@delta / 2.0) +
                @min_val
              )
            }
          when 'midtread'
            @data_series.values.map { |e|
              index_of_quantized_value = ((e - @min_val) / [@delta, GREATER_ZERO].max).round
              (
                (index_of_quantized_value * @delta) +
                @min_val
              )
            }
          else
            raise "Handle this type: #{ @options[:type].inspect }"
          end
        )
      end

    end
  end
end
