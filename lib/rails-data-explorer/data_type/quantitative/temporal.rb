class RailsDataExplorer
  class DataType
    class Quantitative
      class Temporal < Quantitative

        def all_available_chart_types
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

        def descriptive_statistics(values)
          non_nil_values = values.find_all { |e| !e.nil? }
          ruby_formatter = Proc.new { |v| v.nil? ? '' : v.strftime('%a, %b %e, %Y, %l:%M:%S %p %Z') }
          [
            { :label => 'Min', :value => non_nil_values.min, :ruby_formatter => ruby_formatter },
            { :label => 'Max', :value => non_nil_values.max, :ruby_formatter => ruby_formatter },
            { :label => 'Count', :value => values.length, :ruby_formatter => Proc.new { |e| number_with_delimiter(e) } },
          ]
        end

        # Returns an OpenStruct that describes a statistics table.
        def descriptive_statistics_table(values)
          desc_stats = descriptive_statistics(values)
          table = OpenStruct.new(
            :rows => desc_stats.map { |stat|
              OpenStruct.new(
                :css_class => 'rde-row-values',
                :tag => :tr,
                :cells => [
                  OpenStruct.new(:value => stat[:label], :tag => :th, :css_class => 'rde-row_header'),
                  OpenStruct.new(:value => stat[:value], :ruby_formatter => stat[:ruby_formatter], :tag => :td, :css_class => 'rde-cell-value'),
                ]
              )
            }
          )
          table
        end

        def axis_tick_format(values)
          %(function(d) { return d3.time.format('%x')(new Date(d)) })
        end

      end
    end
  end
end
