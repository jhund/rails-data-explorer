class RailsDataExplorer
  class Chart
    class HistogramTemporal < Chart

      def initialize(_data_container, options = {})
        @data_container = _data_container
        @options = {}.merge(options)
      end

      def compute_chart_attrs
        x_ds = @data_container.data_series.first
        # compute histogram
        h = x_ds.values.inject(Hash.new(0)) { |m,e|
          # Round to day
          key = (e.beginning_of_day).to_i * 1000
          m[key] += 1
          m
        }
        {
          values: h.map { |k,v| { x: k, y: v } },
          x_axis_label: x_ds.name,
          x_axis_tick_format: x_ds.axis_tick_format,
          y_axis_label: 'Frequency',
          y_axis_tick_format: "d3.format('r')",
        }
      end

      def render
        return ''  unless render?
        ca = compute_chart_attrs
        %(
          <div class="rde-chart rde-histogram">
            <h3 class="rde-chart-title">Histogram</h3>
            <div id="#{ dom_id }", style="height: 200px;">
              <svg></svg>
            </div>
            <script type="text/javascript">
              (function() {
                var data = [
                  {
                    values: #{ ca[:values].to_json },
                    key: '#{ ca[:x_axis_label] }'
                  }
                ];

                nv.addGraph(function() {
                  var chart = nv.models.historicalBarChart()
                    ;

                  chart.xAxis
                    .axisLabel('#{ ca[:x_axis_label] }')
                    .tickFormat(#{ ca[:x_axis_tick_format] })
                    ;

                  chart.yAxis
                    .axisLabel('#{ ca[:y_axis_label] }')
                    .tickFormat(#{ ca[:y_axis_tick_format] })
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
          </div>
        )
      end

    end
  end
end
