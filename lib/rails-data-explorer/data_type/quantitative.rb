class RailsDataExplorer
  class DataType
    class Quantitative < DataType

      def self.all_available_chart_types
        [
          {
            chart_class: Chart::HistogramQuantitative,
            chart_roles: [:x],
            cardinality_min: 1,
            cardinality_max: 1
          },
          {
            chart_class: Chart::Scatterplot,
            chart_roles: [:x, :y, :size],
            cardinality_min: 2
          },
          {
            chart_class: Chart::DescriptiveStatisticsTable,
            chart_roles: [:any],
            cardinality_min: 1,
            cardinality_max: 1
          },
        ].freeze
      end

      def self.descriptive_statistics(values)
        stats = ::DescriptiveStatistics::Stats.new(values)
        [
          { :label => 'Count', :value => values.length },
          { :label => 'Sum', :value => values.inject(0) { |m,e| m += e } },
          { :label => 'Mean', :value => stats.mean },
          { :label => 'Median', :value => stats.median },
          { :label => 'Mode', :value => stats.mode },
          { :label => 'Range', :value => stats.range },
          { :label => 'Min', :value => stats.min },
          { :label => 'Max', :value => stats.max },
          { :label => 'Variance', :value => stats.variance },
          { :label => 'Standard deviation', :value => stats.standard_deviation },
          { :label => 'Relative standard deviation', :value => stats.relative_standard_deviation },
          { :label => 'Skewness', :value => stats.skewness },
          { :label => 'Kurtosis', :value => stats.kurtosis },
          { :label => '1st Percentile', :value => stats.value_from_percentile(1) },
          { :label => '10th Percentile', :value => stats.value_from_percentile(10) },
          { :label => '25th Percentile', :value => stats.value_from_percentile(25) },
          { :label => '75th Percentile', :value => stats.value_from_percentile(75) },
          { :label => '90th Percentile', :value => stats.value_from_percentile(90) },
          { :label => '99th Percentile', :value => stats.value_from_percentile(99) },
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
