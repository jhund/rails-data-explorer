# -*- coding: utf-8 -*-

class RailsDataExplorer
  class Chart

    # Responsibilities:
    #  * Render a histogram for univariate analysis of a categorical data series.
    #
    # Collaborators:
    #  * DataSet
    #
    class HistogramCategorical < Chart

      def initialize(_data_set, options = {})
        @data_set = _data_set
        @options = {}.merge(options)
      end

      def compute_chart_attrs
        x_ds = @data_set.data_series.first
        return false  if x_ds.nil?

        # compute histogram
        val_mod = { name: :limit_distinct_values }
        h = x_ds.values(val_mod).inject(Hash.new(0)) { |m,e| m[e] += 1; m }
        histogram_values_ds = DataSeries.new('_', h.values)
        y_scale_type = histogram_values_ds.axis_scale(:vega)
        bar_y2_val = 'log' == y_scale_type ? histogram_values_ds.min_val / 10.0 : 0
        {
          values: h.map { |k,v|
            { x: k, y: v }
          }.sort(
            &x_ds.label_sorter(
              :x,
              lambda { |a,b| b[:y] <=> a[:y] }
            )
          ),
          x_axis_label: x_ds.name,
          x_axis_tick_format: "d3.format('r')",
          y_axis_label: 'Frequency',
          y_axis_tick_format: "d3.format(',g')", #histogram_values_ds.axis_tick_format,
          y_scale_type: y_scale_type,
          y_scale_domain: [bar_y2_val, histogram_values_ds.max_val],
          bar_y2_val: bar_y2_val,
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
          <div class="rde-chart rde-histogram-categorical">
            <h3 class="rde-chart-title">Histogram</h3>
            <div id="#{ dom_id }"></div>
            <script type="text/javascript">
              (function() {
                var spec = {
                  "width": 960,
                  "height": 200,
                  "padding": {"top": 10, "left": 70, "bottom": 50, "right": 10},
                  "data": [
                    {
                      "name": "table",
                      "values": #{ ca[:values].to_json }
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
                      "type": "#{ ca[:y_scale_type] }",
                      "range": "height",
                      "domain": #{ ca[:y_scale_domain].to_json },
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
                      "titleOffset": 60,
                      "format": #{ ca[:y_axis_tick_format] },
                    }
                  ],
                  "marks": [
                    {
                      "type": "rect",
                      "from": {"data": "table"},
                      "properties": {
                        "enter": {
                          "x": {"scale": "x", "field": "data.x"},
                          "width": {"scale": "x", "band": true, "offset": -1},
                          "y": {"scale": "y", "field": "data.y"},
                          "y2": {"scale": "y", "value": #{ ca[:bar_y2_val] }},
                        },
                        "update": {
                          "fill": {"value": "#1F77B4"}
                        },
                      }
                    }
                  ]
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
          <div class="rde-chart rde-histogram-categorical">
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
                  var chart = nv.models.discreteBarChart()
                    ;

                  chart.xAxis
                    .axisLabel('#{ ca[:x_axis_label] }')
                    .tickFormat(#{ ca[:x_axis_tick_format] })
                    ;

                  chart.yAxis
                    .axisLabel('#{ ca[:y_axis_label] }')
                    .tickFormat(#{ ca[:y_axis_tick_format] })
                    ;

                  chart.tooltipContent(
                    function(key, x, y, e, graph) {
                      return '<p>' + x + '</p>' + '<p>' +  y + '</p>'
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
