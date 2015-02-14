# -*- coding: utf-8 -*-

class RailsDataExplorer
  class Chart

    # Responsibilities:
    #  * Render a box plot for univariate analysis of a quantitative data series.
    #
    # Collaborators:
    #  * DataSet
    #
    # Resources:
    # * http://johan.github.io/d3/ex/box.html
    # * http://bl.ocks.org/mbostock/4061502
    class BoxPlot < Chart

      def initialize(_data_set, options = {})
        @data_set = _data_set
        @options = {}.merge(options)
      end

      def compute_chart_attrs
        x_ds = @data_set.data_series.first
        return false  if x_ds.nil?

        {
          values: [x_ds.values],
          min: x_ds.min_val,
          max: x_ds.max_val,
          base_width: 120,
          base_height: 960,
          axis_tick_format: x_ds.axis_tick_format,
        }
      end

      def render
        return ''  unless render?
        ca = compute_chart_attrs
        return ''  unless ca

        %(
          <div id="#{ dom_id }" class="rde-chart rde-box-plot">
            <svg class="box" style="height: #{ ca[:base_width] }px; width: 100%;"></svg>

            <script type="text/javascript">
              (function() {
                var base_width = #{ ca[:base_width] },
                    base_height = #{ ca[:base_height] },
                    margin = { top: 10, right: 50, bottom: 95, left: 50 },
                    width = base_width - margin.left - margin.right,
                    height = base_height - margin.top - margin.bottom;

                var min = #{ ca[:min] },
                    max = #{ ca[:max] };

                var chart = d3.box()
                              .whiskers(iqr(1.5))
                              .width(width)
                              .height(height)
                              .tickFormat(#{ ca[:axis_tick_format] });

                var data = #{ ca[:values].to_json };

                chart.domain([min, max]);

                var svg = d3.select("##{ dom_id }").selectAll("svg")
                            .data(data)
                          .append("g")
                            .attr("transform", "rotate(90) translate(" + (width + margin.left) + " -" + (height + margin.bottom) + ")")
                            .call(chart);

                // Function to compute the interquartile range.
                function iqr(k) {
                  return function(d, i) {
                    var q1 = d.quartiles[0],
                        q3 = d.quartiles[2],
                        iqr = (q3 - q1) * k,
                        i = -1,
                        j = d.length;
                    while (d[++i] < q1 - iqr);
                    while (d[--j] > q3 + iqr);
                    return [i, j];
                  };
                }
              })();
            </script>
          </div>
        )
      end

    end
  end
end
