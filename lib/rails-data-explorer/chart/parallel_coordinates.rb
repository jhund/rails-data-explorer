class RailsDataExplorer
  class Chart
    class ParallelCoordinates < Chart

      def initialize(_data_container, options = {})
        @data_container = _data_container
        @options = {}.merge(options)
      end

      def render
        return ''  unless render?
        ca = compute_chart_attrs
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

      # Don't render ParallelCoordinates when all data series are categorical.
      # ParallelSet is much better suited for that use case.
      def render?
        !@data_container.data_series.all? { |ds|
          RailsDataExplorer::DataType::Categorical == ds.data_type
        }
      end

      def compute_chart_attrs
        dimension_data_series = @data_container.data_series.find_all { |ds|
          (ds.chart_roles[Chart::ParallelCoordinates] & [:dimension, :any]).any?
        }
        dimension_names = dimension_data_series.map(&:name)
        number_of_values = dimension_data_series.first.values.length
        dimension_values = number_of_values.times.map do |idx|
          dimension_data_series.inject({}) { |m,ds|
            m[ds.name] = if RailsDataExplorer::DataType::Quantitative::Temporal == ds.data_type
              ds.values[idx].to_i * 1000
            else
              ds.values[idx]
            end
            m
          }
        end
        dimension_types = dimension_data_series.inject({}) { |m,ds|
          m[ds.name] = if RailsDataExplorer::DataType::Categorical == ds.data_type
            'string'
          elsif RailsDataExplorer::DataType::Quantitative::Temporal == ds.data_type
            'date'
          elsif [RailsDataExplorer::DataType::Quantitative::Integer, RailsDataExplorer::DataType::Quantitative::Decimal].include?(ds.data_type)
            'number'
          else
            raise "Unhandled data_type: #{ ds.data_type.inspect }"
          end
          m
        }
        {
          :dimensions => dimension_names,
          :values => dimension_values,
          :types => dimension_types,
          :alpha => 1 / ([Math.log([number_of_values, 2].max), 10].min) # from 1.0 to 0.1
        }
      end

    end
  end
end
