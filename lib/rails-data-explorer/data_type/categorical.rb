class RailsDataExplorer
  class DataType
    class Categorical < DataType

      def self.all_available_chart_types
        [
          {
            :chart_class => Chart::HistogramCategorical,
            :chart_roles => [:x],
            :cardinality_min => 1,
            :cardinality_max => 1,
          },
          {
            :chart_class => Chart::PieChart,
            :chart_roles => [:any],
            :cardinality_min => 1,
            :cardinality_max => 1,
          },
          {
            chart_class: Chart::BoxPlotGroup,
            chart_roles: [:x],
            cardinality_min: 2,
            cardinality_max: 2,
          },
          {
            chart_class: Chart::Scatterplot,
            chart_roles: [:color],
            cardinality_min: 3,
          },
          {
            chart_class: Chart::ParallelCoordinates,
            chart_roles: [:dimension],
            cardinality_min: 3,
          },
          {
            chart_class: Chart::StackedBarChartCategoricalPercent,
            chart_roles: [:x, :y],
            cardinality_min: 2,
            cardinality_max: 2,
          },
          {
            chart_class: Chart::ContingencyTable,
            chart_roles: [:any],
            cardinality_min: 2,
            cardinality_max: 2,
          },
          {
            chart_class: Chart::DescriptiveStatisticsTable,
            chart_roles: [:any],
            cardinality_min: 1,
            cardinality_max: 1,
          },
        ].freeze
      end

      def self.descriptive_statistics(values)
        frequencies = values.inject(Hash.new(0)) { |m,e| m[e] += 1; m }
        total_count = values.length
        r = frequencies.map { |k,v|
          { :label => k.to_s, :value => "#{ v } (#{ (v / total_count.to_f) * 100 }%)" }
        }.sort { |a,b| b[:value] <=> a[:value] }
        r << { :label => 'Total count', :value => total_count }
        r
      end

      def self.axis_tick_format(values)
        %(function(d) { return d })
      end

    end
  end
end
