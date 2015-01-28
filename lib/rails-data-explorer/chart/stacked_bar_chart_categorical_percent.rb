class RailsDataExplorer
  class Chart
    class StackedBarChartCategoricalPercent < Chart

      def initialize(_data_set, options = {})
        @data_set = _data_set
        @options = {}.merge(options)
      end

      def compute_chart_attrs
        x_candidates = @data_set.data_series.find_all { |ds|
          (ds.chart_roles[Chart::StackedBarChartCategoricalPercent] & [:x, :any]).any?
        }.sort { |a,b| b.uniq_vals.length <=> a.uniq_vals.length }
        y_candidates = @data_set.data_series.find_all { |ds|
          (ds.chart_roles[Chart::StackedBarChartCategoricalPercent] & [:y, :any]).any?
        }

        x_ds = x_candidates.first
        y_ds = (y_candidates - [x_ds]).first
        return false  if x_ds.nil? || y_ds.nil?

        # initialize data_matrix
        data_matrix = { _sum: { _sum: 0 } }
        x_ds.uniq_vals.each { |x_val|
          data_matrix[x_val] = {}
          data_matrix[x_val][:_sum] = 0
          y_ds.uniq_vals.each { |y_val|
            data_matrix[x_val][y_val] = 0
            data_matrix[:_sum][y_val] = 0
          }
        }
        # populate data_matrix
        x_ds.values.length.times { |idx|
          x_val = x_ds.values[idx]
          y_val = y_ds.values[idx]
          data_matrix[x_val][y_val] += 1
          data_matrix[:_sum][y_val] += 1
          data_matrix[x_val][:_sum] += 1
          data_matrix[:_sum][:_sum] += 1
        }

        x_sorted_keys = x_ds.uniq_vals.sort(
          &x_ds.label_sorter(
            nil,
            lambda { |a,b| data_matrix[b][:_sum] <=> data_matrix[a][:_sum] }
          )
        )
        y_sorted_keys = y_ds.uniq_vals.sort(
          &y_ds.label_sorter(
            nil,
            lambda { |a,b| data_matrix[:_sum][b] <=> data_matrix[:_sum][a] }
          )
        )

        values = case @data_set.dimensions_count
        when 2
          y_sorted_keys.map { |y_val|
            x_sorted_keys.map { |x_val|
              {
                x: x_val,
                y: (data_matrix[x_val][y_val] / data_matrix[x_val][:_sum].to_f) * 100,
                c: y_val
              }
            }
          }.flatten
        else
          raise(ArgumentError.new("Exactly two data series required for contingency table."))
        end
        {
          values: values,
          x_axis_label: x_ds.name,
          x_axis_tick_format: 'function(d) { return d }',
          y_axis_label: "#{ y_ds.name } distribution [%]",
          y_axis_tick_format: "d3.format('.1%')",
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
          <div class="rde-chart rde-stacked-bar-chart-categorical-percent">
            <h3 class="rde-chart-title">Stacked Bar Chart</h3>
            <div id="#{ dom_id }"></div>
            <script type="text/javascript">
              (function() {
                var spec = {
                  "width": 800,
                  "height": 200,
                  "padding": {"top": 10, "left": 50, "bottom": 50, "right": 100},
                  "data": [
                    {
                      "name": "table",
                      "values": #{ ca[:values].to_json }
                    },
                    {
                      "name": "stats",
                      "source": "table",
                      "transform": [
                        {"type": "facet", "keys": ["data.x"]},
                        {"type": "stats", "value": "data.y"}
                      ]
                    }
                  ],
                  "scales": [
                    {
                      "name": "x",
                      "type": "ordinal",
                      "range": "width",
                      "domain": {"data": "table", "field": "data.x"}
                    },
                    {
                      "name": "y",
                      "type": "linear",
                      "range": "height",
                      "nice": true,
                      "domain": {"data": "stats", "field": "sum"}
                    },
                    {
                      "name": "color",
                      "type": "ordinal",
                      "range": "category10"
                    }
                  ],
                  "axes": [
                    {
                      "type": "x",
                      "scale": "x",
                      "title": "#{ ca[:x_axis_label] }",
                      "format": #{ ca[:x_axis_tick_format] },
                    },
                    {
                      "type": "y",
                      "scale": "y",
                      "title": "#{ ca[:y_axis_label] }",
                      "format": #{ ca[:y_axis_tick_format] },
                    }
                  ],
                  "marks": [
                    {
                      "type": "group",
                      "from": {
                        "data": "table",
                        "transform": [
                          {"type": "facet", "keys": ["data.c"]},
                          {"type": "stack", "point": "data.x", "height": "data.y"}
                        ]
                      },
                      "marks": [
                        {
                          "type": "rect",
                          "properties": {
                            "enter": {
                              "x": {"scale": "x", "field": "data.x"},
                              "width": {"scale": "x", "band": true, "offset": -1},
                              "y": {"scale": "y", "field": "y"},
                              "y2": {"scale": "y", "field": "y2"},
                              "fill": {"scale": "color", "field": "data.c"}
                            },
                          }
                        }
                      ]
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
          <div class="rde-chart rde-stacked-bar-chart-categorical-percent">
            <h3 class="rde-chart-title">Stacked Bar Chart</h3>
            <div id="#{ dom_id }", style="height: 200px;">
              <svg></svg>
            </div>
            <script type="text/javascript">
              (function() {
                var data = #{ ca[:values].to_json };

                nv.addGraph(function() {
                  var chart = nv.models.multiBarChart()
                    ;

                  chart.xAxis
                    .axisLabel('#{ ca[:x_axis_label] }')
                    .tickFormat(#{ ca[:x_axis_tick_format] })
                    ;

                  chart.yAxis
                    .axisLabel('#{ ca[:y_axis_label] }')
                    .tickFormat(#{ ca[:y_axis_tick_format] })
                    ;

                  chart.multibar.stacked(true);
                  chart.showControls(false);
                  chart.tooltipContent(
                    function(key, x, y, e, graph) {
                      return '<p>' + key + '</p>' + '<p>' +  y + ' of ' + x + '</p>'
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
