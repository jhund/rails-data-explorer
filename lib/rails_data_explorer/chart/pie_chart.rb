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

        val_mod = { name: :limit_distinct_values }
        total_count = x_ds.values(val_mod).length
        # compute histogram
        h = x_ds.values(val_mod).inject(Hash.new(0)) { |m,e| m[e] += 1; m }
        {
          values: h.map { |k,v|
            { key: k, value: (v / total_count.to_f) }
          }.sort(
            &x_ds.label_sorter(
              :key,
              lambda { |a,b| b[:value] <=> a[:value] }
            )
          )
        }
      end

      def render
        return ''  unless render?
        ca = compute_chart_attrs
        return ''  unless ca
        render_vega(ca)
      end

      def render_vega(ca)
        %(
          <div class="rde-chart rde-pie-chart">
            <h3 class="rde-chart-title">Pie Chart</h3>
            <div id="#{ dom_id }"></div>
            <script type="text/javascript">
              (function() {
                var spec = {
                  "width": 300,
                  "height": 300,
                  "padding": {"top": 10, "left": 10, "bottom": 10, "right": 100},
                  "data": [
                    {
                      "name": "table",
                      "values": #{ ca[:values].to_json }
                    }
                  ],
                  "scales": [
                    {
                      "name": "color",
                      "domain": {"data": "table", "field": "data.key"},
                      "range": "category10",
                      "type": "ordinal"
                    },
                  ],
                  "axes": [],
                  "marks": [
                    {
                      "type": "arc",
                      "from": {
                        "data": "table",
                        "transform": [{"type": "pie", "value": "data.value"}]
                      },
                      "properties": {
                        "enter": {
                          "x": {"group": "width", "mult": 0.5},
                          "y": {"group": "height", "mult": 0.5},
                          "endAngle": {"field": "endAngle"},
                          "innerRadius": {"value": 100},
                          "outerRadius": {"value": 150},
                          "startAngle": {"field": "startAngle"},
                          "stroke": {"value": "white"},
                          "fill": {"field": "data.key", "scale": "color"}
                        }
                      }
                    }
                  ],
                  "legends": [
                    {
                      "fill": "color",
                    }
                  ],
                };

                vg.parse.spec(spec, function(chart) {
                  var view = chart({ el:"##{ dom_id }" }).update();
                });

              })();
            </script>
          </div>
        )
      end

      def render_nvd3(ca)
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

    end
  end
end
