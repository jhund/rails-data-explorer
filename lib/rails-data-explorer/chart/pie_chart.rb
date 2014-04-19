class RailsDataExplorer
  class Chart
    class PieChart < Chart

      def initialize(_data_set, options = {})
        @data_set = _data_set
        @options = {}.merge(options)
      end

      def compute_chart_attrs
        x_ds = @data_set.data_series.first
        return false  if x_ds.nil?

        total_count = x_ds.values.length
        # compute histogram
        h = x_ds.values.inject(Hash.new(0)) { |m,e| m[e] += 1; m }
        {
          values: h.map { |k,v|
                    { x: k, y: (v / total_count.to_f) }
                  }.sort { |a,b|
                    b[:y] <=> a[:y]
                  },
          x_axis_label: x_ds.name,
          x_axis_tick_format: "",
          y_axis_label: 'Frequency',
          y_axis_tick_format: "d3.format('r')",
        }
      end

      def render
        return ''  unless render?
        ca = compute_chart_attrs
        return ''  unless ca

        %(
          <div class="rde-chart rde-pie-chart">
            <h3 class="rde-chart-title">Pie Chart</h3>
            <div id="#{ dom_id }", style="height: 400px; width: 400px;">
              <svg></svg>
            </div>
            <script type="text/javascript">
              (function() {
                var data = #{ ca[:values].to_json };

                nv.addGraph(function() {
                  var chart = nv.models.pieChart()
                    ;

                  chart.valueFormat(d3.format('.1%'))
                       .donut(true)
                    ;
                  chart.tooltipContent(
                    function(key, y, e, graph) {
                      return '<p>' + key + '</p>' + '<p>' +  y + '</p>'
                    }
                  );

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

      # Render PieChart only if there is a fairly small number of
      # distinct values.
      def render?
        !@data_set.data_series.first.has_many_uniq_vals?
      end

    end
  end
end
