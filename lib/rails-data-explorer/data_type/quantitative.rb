class RailsDataExplorer
  class DataType
    class Quantitative < DataType

      def self.all_available_chart_types
        [
          {
            chart_class: Chart::HistogramQuantitative,
            chart_roles: [:x],
            dimensions_count_min: 1,
            dimensions_count_max: 1
          },
          {
            chart_class: Chart::BoxPlotGroup,
            chart_roles: [:y],
            dimensions_count_min: 2,
            dimensions_count_max: 2,
          },
          {
            chart_class: Chart::Scatterplot,
            chart_roles: [:x, :y, :size],
            dimensions_count_min: 2
          },
          {
            chart_class: Chart::DescriptiveStatisticsTable,
            chart_roles: [:any],
            dimensions_count_min: 1,
            dimensions_count_max: 1
          },
          {
            chart_class: Chart::ParallelCoordinates,
            chart_roles: [:dimension],
            dimensions_count_min: 3,
          },
        ].freeze
      end

      def self.descriptive_statistics(values)
        stats = ::DescriptiveStatistics::Stats.new(values)
        ruby_formatters = {
          :integer => Proc.new { |v| number_with_delimiter(v.round) },
          :decimal => Proc.new { |v| number_with_precision(v, :precision => 5, :significant => true, :strip_insignificant_zeros => true, :delimiter => ',') },
        }
        [
          { :label => 'Count', :value => values.length, :ruby_formatter => ruby_formatters[:integer] },
          { :label => 'Sum', :value => values.inject(0) { |m,e| m += e }, :ruby_formatter => ruby_formatters[:decimal] },
          { :label => 'Mean', :value => stats.mean, :ruby_formatter => ruby_formatters[:decimal] },
          { :label => 'Mode', :value => stats.mode, :ruby_formatter => ruby_formatters[:decimal] },
          { :label => 'Range', :value => stats.range, :ruby_formatter => ruby_formatters[:decimal] },
          { :label => 'Variance', :value => stats.variance, :ruby_formatter => ruby_formatters[:decimal] },
          { :label => 'Standard deviation', :value => stats.standard_deviation, :ruby_formatter => ruby_formatters[:decimal] },
          { :label => 'Relative standard deviation', :value => stats.relative_standard_deviation, :ruby_formatter => ruby_formatters[:decimal] },
          { :label => 'Skewness', :value => stats.skewness, :ruby_formatter => ruby_formatters[:decimal] },
          { :label => 'Kurtosis', :value => stats.kurtosis, :ruby_formatter => ruby_formatters[:decimal] },
          { :label => 'Min', :value => stats.min, :ruby_formatter => ruby_formatters[:decimal] },
          { :label => '1st Percentile', :value => stats.value_from_percentile(1), :ruby_formatter => ruby_formatters[:decimal] },
          { :label => '10th Percentile', :value => stats.value_from_percentile(10), :ruby_formatter => ruby_formatters[:decimal] },
          { :label => '25th Percentile', :value => stats.value_from_percentile(25), :ruby_formatter => ruby_formatters[:decimal] },
          { :label => 'Median', :value => stats.median, :ruby_formatter => ruby_formatters[:decimal] },
          { :label => '75th Percentile', :value => stats.value_from_percentile(75), :ruby_formatter => ruby_formatters[:decimal] },
          { :label => '90th Percentile', :value => stats.value_from_percentile(90), :ruby_formatter => ruby_formatters[:decimal] },
          { :label => '99th Percentile', :value => stats.value_from_percentile(99), :ruby_formatter => ruby_formatters[:decimal] },
          { :label => 'Max', :value => stats.max, :ruby_formatter => ruby_formatters[:decimal] },
        ]
      end

      def self.axis_tick_format(values)
        case values.first
        when Integer, Bignum, Fixnum
          "d3.format('r')"
        when Float
          "d3.format('.02f')"
        else
          raise "Handle this number format: #{ values.first.class.to_s }"
        end
      end

    end
  end
end
