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
            chart_class: Chart::Scatterplot,
            chart_roles: [:color],
            cardinality_min: 3,
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
        distribution = values.inject(Hash.new(0)) { |m,e| m[e] += 1; m }
        r = [
          { :label => 'Total count', :value => values.length },
        ]
        r += distribution.map { |k,v| { :label => k.to_s, :value => v } }
      end

      def self.axis_tick_format(values)
        %(function(d) { return d })
      end

    end
  end
end
