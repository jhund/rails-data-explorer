class RailsDataExplorer
  class DataType
    class Temporal < DataType

      def self.all_available_chart_types
        [
          {
            :chart_class => Chart::HistogramTemporal,
            :chart_roles => [:x],
            :cardinality_min => 1,
            :cardinality_max => 1
          },
          {
            chart_class: Chart::DescriptiveStatisticsTable,
            chart_roles: [:any],
            cardinality_min: 1,
            cardinality_max: 1
          },
          {
            chart_class: Chart::ParallelCoordinates,
            chart_roles: [:dimension],
            cardinality_min: 3,
          },
        ].freeze
      end

      def self.descriptive_statistics(values)
        [
          { :label => 'Count', :value => values.length },
          { :label => 'Min', :value => values.min },
          { :label => 'Max', :value => values.max },
        ]
      end

      def self.axis_tick_format(values)
        %(function(d) { return d3.time.format('%x')(new Date(d)) })
      end

    end
  end
end
