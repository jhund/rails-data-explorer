class RailsDataExplorer
  class DataType
    class Categorical < DataType

      def self.all_available_chart_types
        [
          {
            :chart_class => Chart::HistogramCategorical,
            :chart_roles => [:x],
            :dimensions_count_min => 1,
            :dimensions_count_max => 1,
          },
          {
            :chart_class => Chart::PieChart,
            :chart_roles => [:any],
            :dimensions_count_min => 1,
            :dimensions_count_max => 1,
          },
          {
            chart_class: Chart::BoxPlotGroup,
            chart_roles: [:x],
            dimensions_count_min: 2,
            dimensions_count_max: 2,
          },
          {
            chart_class: Chart::Scatterplot,
            chart_roles: [:color],
            dimensions_count_min: 3,
          },
          {
            chart_class: Chart::ParallelCoordinates,
            chart_roles: [:dimension],
            dimensions_count_min: 3,
          },
          {
            chart_class: Chart::StackedBarChartCategoricalPercent,
            chart_roles: [:x, :y],
            dimensions_count_min: 2,
            dimensions_count_max: 2,
          },
          {
            chart_class: Chart::ContingencyTable,
            chart_roles: [:any],
            dimensions_count_min: 2,
            dimensions_count_max: 2,
          },
          {
            chart_class: Chart::DescriptiveStatisticsTable,
            chart_roles: [:any],
            dimensions_count_min: 1,
            dimensions_count_max: 1,
          },
          {
            chart_class: Chart::ParallelSet,
            chart_roles: [:dimension],
            dimensions_count_min: 3,
          },
        ].freeze
      end

      def self.descriptive_statistics(values)
        frequencies = values.inject(Hash.new(0)) { |m,e| m[e] += 1; m }
        total_count = values.length
        r = frequencies.map { |k,v|
          { :label => k.to_s, :value => "#{ v } (#{ (v / total_count.to_f) * 100 }%)", :ruby_formatter => Proc.new { |e| e } }
        }.sort { |a,b| b[:value] <=> a[:value] }
        r << { :label => 'Total count', :value => total_count, :ruby_formatter => Proc.new { |e| e } }
        r
      end

      def self.axis_tick_format(values)
        %(function(d) { return d })
      end

    end
  end
end
