# Map a large set of quantitative/temporal/geo input values to a (countable)
# smaller set – such as rounding values to some unit of precision.
class RailsDataExplorer
  module Utils
    class DataQuantizer

      attr_accessor :number_of_bins, :quantization_interval

      def initialize(data_series, options = {})
        options = {
          :type => 'midrise', # 'midtread'
          :max_number_of_bins => 800, # one per horizontal pixel
        }.merge(options)
        @data_series = data_series
        @number_of_bins = [
          [
            @data_series.uniq_vals_count,
            options[:max_number_of_bins]
          ].min,
          20
        ].max
      end

      def values
        @values ||= (
          min_val = @data_series.min_val
          max_val = @data_series.max_val
          @quantization_interval = (max_val - min_val) / @number_of_bins.to_f
          if @number_of_bins == @data_series.uniq_vals_count
            @data_series.values
          else
            @data_series.values.map { |e|
              index_of_quantized_value = ((e - min_val) / @quantization_interval).round
              (
                (index_of_quantized_value * @quantization_interval) +
                (@quantization_interval / 2.0) +
                min_val
              )
            }
          end
        )
      end

    end
  end
end
