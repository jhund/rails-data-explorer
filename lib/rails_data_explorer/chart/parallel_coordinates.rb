# TODO: add :color chart_role (test first if it makes sense, e.g., for 'pay')
class RailsDataExplorer
  class Chart
    class ParallelCoordinates < Chart

      def initialize(_data_set, options = {})
        @data_set = _data_set
        @options = {}.merge(options)
      end

      def render
        return ''  unless render?
        ca = compute_chart_attrs
        return ''  unless ca

        %(
          <div class="rde-chart rde-parallel-coordinates">
            <h3 class="rde-chart-title">Parallel coordinates</h3>
            <div id="#{ dom_id }" class="rde-chart-parallel-coordinates parcoords" style="height: 400px; width: 100%"></div>
            <script type="text/javascript">
              (function() {
                var parcoords = d3.parcoords()("##{ dom_id }")
                                  .dimensions(#{ ca[:dimensions ].to_json })
                                  .types(#{ ca[:types].to_json })
                                  .alpha(#{ ca[:alpha] })
                                  ;

                parcoords.data(#{ ca[:values].to_json })
                         .render()
                         .createAxes() // has to come before other methods that rely on axes (e.g., brushable)
                         // .shadows() // they don't redraw after reordering, so I'm turning them off for now.
                         .reorderable()
                         .brushable()
                         ;

              })();
            </script>
          </div>
        )
      end

      # Render ParallelCoordinates only when there is at least one data series
      # with DataType Quantitative. If it's all Categorical, then ParallelSet
      # is much better suited.
      def render?
        @data_set.data_series.any? { |ds|
          ds.data_type.is_a?(RailsDataExplorer::DataType::Quantitative)
        }
      end

      def compute_chart_attrs
        dimension_data_series = @data_set.data_series.find_all { |ds|
          (ds.chart_roles[Chart::ParallelCoordinates] & [:dimension, :any]).any?
        }
        return false  if dimension_data_series.empty?

        dimension_names = dimension_data_series.map(&:name)
        number_of_values = dimension_data_series.first.values.length
        dimension_values = number_of_values.times.map do |idx|
          dimension_data_series.inject({}) { |m,ds|
            m[ds.name] = if ds.data_type.is_a?(RailsDataExplorer::DataType::Quantitative::Temporal)
              ds.values[idx].to_i * 1000
            else
              ds.values[idx]
            end
            m
          }
        end
        dimension_types = dimension_data_series.inject({}) { |m,ds|
          m[ds.name] = case ds.data_type
          when RailsDataExplorer::DataType::Categorical
            'string'
          when RailsDataExplorer::DataType::Quantitative::Temporal
            'date'
          when RailsDataExplorer::DataType::Quantitative::Integer,
               RailsDataExplorer::DataType::Quantitative::Decimal
            'number'
          else
            raise "Unhandled data_type: #{ ds.data_type.inspect }"
          end
          m
        }
        {
          dimensions: dimension_names,
          values: dimension_values,
          types: dimension_types,
          alpha: 1 / ([Math.log([number_of_values, 2].max), 10].min) # from 1.0 to 0.1
        }
      end

    end
  end
end
