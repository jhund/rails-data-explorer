class RailsDataExplorer
  class Chart
    class ParallelCoordinates < Chart

      def initialize(_data_container, options = {})
        @data_container = _data_container
        @options = {}.merge(options)
      end

      def compute_chart_attrs
        dimension_data_series = @data_container.data_series.find_all { |ds|
          (ds.chart_roles[Chart::ParallelCoordinates] & [:dimension, :any]).any?
        }
        dimension_names = dimension_data_series.map { |e| e.name }
        dimension_values = dimension_data_series.first.values.length.times.map do |idx|
          dimension_data_series.inject({}) { |m,ds|
            m[ds.name] = ds.values[idx]
            m
          }
        end

        {
          :values => dimension_values,
          :dimensions => dimension_names
        }
      end

      def render
        ca = compute_chart_attrs
        %(
          <h3 class="rde-chart-title">Parallel coordinates</h3>
          <div id="#{ dom_id }", style="height: 600px;">
            <svg></svg>
          </div>
          <script type="text/javascript">
            (function() {
              var data = #{ ca[:values].to_json };

              nv.addGraph(function() {
                var chart = nv.models.parallelCoordinates()
                  ;

                chart.dimensions(#{ ca[:dimensions].to_json })
                  ;

                d3.select('##{ dom_id } svg')
                  .datum(data)
                  .transition().duration(100)
                  .call(chart)
                  ;

                nv.utils.windowResize(chart.update);

                return chart;
              });
            })();
          </script>
        )
      end

    end
  end
end
