class RailsDataExplorer
  class DataType
    class Quantitative
      class Temporal < Quantitative

        def self.all_available_chart_types
          [
            {
              :chart_class => Chart::HistogramTemporal,
              :chart_roles => [:x],
              :dimensions_count_min => 1,
              :dimensions_count_max => 1
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
          ruby_formatter = Proc.new { |v| v.nil? ? '' : v.strftime('%a, %b %e, %Y, %l:%M:%S %p %Z') }
          [
            { :label => 'Count', :value => values.length, :ruby_formatter => Proc.new { |e| number_with_delimiter(e) } },
            { :label => 'Min', :value => values.min, :ruby_formatter => ruby_formatter },
            { :label => 'Max', :value => values.max, :ruby_formatter => ruby_formatter },
          ]
        end

        def self.axis_tick_format(values)
          %(function(d) { return d3.time.format('%x')(new Date(d)) })
        end

      end
    end
  end
end
