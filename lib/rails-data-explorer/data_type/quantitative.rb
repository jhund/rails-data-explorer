class RailsDataExplorer
  class DataType
    class Quantitative < DataType

      # This is an abstract class. Use sub_classes

      def all_available_chart_types
        [
          # {
          #   chart_class: Chart::BoxPlot,
          #   chart_roles: [:y],
          #   dimensions_count_min: 1,
          #   dimensions_count_max: 1
          # },
          {
            chart_class: Chart::HistogramQuantitative,
            chart_roles: [:x],
            dimensions_count_min: 1,
            dimensions_count_max: 1
          },
          {
            chart_class: Chart::BoxPlotGroup,
            chart_roles: [:x],
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

      def descriptive_statistics(values)
        non_nil_values = values.find_all { |e| !(e.nil? || Float::NAN == e) }
        stats = ::DescriptiveStatistics::Stats.new(non_nil_values)
        ruby_formatters = {
          :integer => Proc.new { |v|
            v.nil? ? 'Null' : number_with_delimiter(v.round)
          },
          :decimal => Proc.new { |v|
            case
            when v.nil?
              'Null'
            when v.is_a?(Float) && v.nan?
              'NaN'
            else
              number_with_precision(
                v,
                :precision => 3,
                :significant => true,
                :strip_insignificant_zeros => true,
                :delimiter => ','
              )
            end
          },
          :pass_through => Proc.new { |v| (v.nil? || Float::NAN == v) ? 'NaN' : v },
        }
        [
          { :label => 'Min', :value => stats.min, :ruby_formatter => ruby_formatters[:decimal], :table_row => 1 },
          { :label => '1%ile', :value => stats.value_from_percentile(1), :ruby_formatter => ruby_formatters[:decimal], :table_row => 1 },
          { :label => '5%ile', :value => stats.value_from_percentile(5), :ruby_formatter => ruby_formatters[:decimal], :table_row => 1 },
          { :label => '10%ile', :value => stats.value_from_percentile(10), :ruby_formatter => ruby_formatters[:decimal], :table_row => 1 },
          { :label => '25%ile', :value => stats.value_from_percentile(25), :ruby_formatter => ruby_formatters[:decimal], :table_row => 1 },
          { :label => 'Median', :value => stats.median, :ruby_formatter => ruby_formatters[:decimal], :table_row => 1 },
          { :label => '75%ile', :value => stats.value_from_percentile(75), :ruby_formatter => ruby_formatters[:decimal], :table_row => 1 },
          { :label => '90%ile', :value => stats.value_from_percentile(90), :ruby_formatter => ruby_formatters[:decimal], :table_row => 1 },
          { :label => '95%ile', :value => stats.value_from_percentile(95), :ruby_formatter => ruby_formatters[:decimal], :table_row => 1 },
          { :label => '99%ile', :value => stats.value_from_percentile(99), :ruby_formatter => ruby_formatters[:decimal], :table_row => 1 },
          { :label => 'Max', :value => stats.max, :ruby_formatter => ruby_formatters[:decimal], :table_row => 1 },

          { :label => 'Range', :value => stats.range, :ruby_formatter => ruby_formatters[:decimal], :table_row => 2 },
          { :label => 'Mean', :value => stats.mean, :ruby_formatter => ruby_formatters[:decimal], :table_row => 2 },
          { :label => 'Mode', :value => stats.mode, :ruby_formatter => ruby_formatters[:decimal], :table_row => 2 },
          { :label => 'Count', :value => values.length, :ruby_formatter => ruby_formatters[:integer], :table_row => 2 },
          { :label => 'Sum', :value => non_nil_values.inject(0) { |m,e| m += e }, :ruby_formatter => ruby_formatters[:decimal], :table_row => 2 },
          { :label => 'Variance', :value => stats.variance, :ruby_formatter => ruby_formatters[:decimal], :table_row => 2 },
          { :label => 'Std. dev.', :value => stats.standard_deviation, :ruby_formatter => ruby_formatters[:decimal], :table_row => 2 },
          { :label => 'Rel. std. dev.', :value => stats.relative_standard_deviation, :ruby_formatter => ruby_formatters[:decimal], :table_row => 2 },
          { :label => 'Skewness', :value => stats.skewness, :ruby_formatter => ruby_formatters[:decimal], :table_row => 2 },
          { :label => 'Kurtosis', :value => stats.kurtosis, :ruby_formatter => ruby_formatters[:decimal], :table_row => 2 },
          { :label => '', :value => '', :ruby_formatter => ruby_formatters[:pass_through], :table_row => 2 },
        ]
      end

      # Returns an object that describes a statistics table.
      def descriptive_statistics_table(values)
        desc_stats = descriptive_statistics(values)
        table = Utils::RdeTable.new([])
        [1,2].each do |table_row|
          table.rows << Utils::RdeTableRow.new(
            :tr,
            desc_stats.find_all { |e| table_row == e[:table_row] }.map { |stat|
              Utils::RdeTableCell.new(:th, stat[:label], ruby_formatter: Proc.new { |e| e }, css_class: 'rde-cell-label')
            },
            css_class: 'rde-column_header'
          )
          table.rows << Utils::RdeTableRow.new(
            :tr,
            desc_stats.find_all { |e| table_row == e[:table_row] }.map { |stat|
              Utils::RdeTableCell.new(:td, stat[:value], ruby_formatter: stat[:ruby_formatter], css_class: 'rde-cell-value')
            },
            css_class: 'rde-data_row'
          )
        end
        table
      end

      def axis_tick_format(values)
        raise "Implement me in sub_class"
      end

      def axis_scale(data_series, d3_or_vega)
        # Log scales can't handle 0 values
        if data_series.min_val > 0.0 && data_series.has_large_dynamic_range?
          { d3: 'd3.scale.log', vega: 'log' }[d3_or_vega]
        else
          { d3: 'd3.scale.linear', vega: 'linear' }[d3_or_vega]
        end
      end

    end
  end
end
