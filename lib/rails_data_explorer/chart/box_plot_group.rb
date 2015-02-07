# -*- coding: utf-8 -*-

class RailsDataExplorer
  class Chart

    # Responsibilities:
    #  * Render a group of box plots for bivariate analysis of a categorical and
    #    a numerical data series. One box plot is rendered for each distinct
    #    categorical value.
    #
    # Collaborators:
    #  * DataSet
    #
    # http://bl.ocks.org/jensgrubert/7789216
    # http://www.datavizcatalogue.com/methods/box_plot.html#.U0S8Ra1dUyE
    # http://mbostock.github.io/protovis/ex/box-and-whisker.html
    # http://bl.ocks.org/mbostock/4061502
    # http://johan.github.io/d3/ex/box.html
    # http://johan.github.io/d3/ex/box.html
    # http://bl.ocks.org/mbostock/4061502
    # TODO: imitate this:
    # http://www.stata.com/support/faqs/graphics/gph/graphdocs/horizontal-box-plot-of-variable-by-values-of-categorical-variable/
    class BoxPlotGroup < Chart

      def initialize(_data_set, options = {})
        @data_set = _data_set
        @options = {}.merge(options)
      end

      def compute_chart_attrs
        x_candidates = @data_set.data_series.find_all { |ds|
          (ds.chart_roles[Chart::BoxPlotGroup] & [:x, :any]).any?
        }
        y_candidates = @data_set.data_series.find_all { |ds|
          (ds.chart_roles[Chart::BoxPlotGroup] & [:y, :any]).any?
        }
        x_ds = x_candidates.first
        y_ds = (y_candidates - [x_ds]).first
        return false  if x_ds.nil? || y_ds.nil?

        # initialize values_hash
        values_hash = y_ds.uniq_vals.inject({}) { |m,y_val|
          m[y_val] = []
          m
        }
        # populate values hash
        y_ds.values.each_with_index { |y_val, idx|
          next  if (y_val.nil? || Float::NAN == y_val)
          values_hash[y_val] << x_ds.values[idx]
        }
        y_sorted_keys = y_ds.uniq_vals.sort(
          &y_ds.label_sorter(
            nil,
            lambda { |a,b| a <=> b }
          )
        )
        sorted_values = y_sorted_keys.map { |y_val| values_hash[y_val] }

        # Compute min and max values based on interquartile range of each
        # boxplot. Objective is to normalize boxplots so that the widest chart
        # uses almost the entire space available.
        # Iterate over all individual boxplots
        global_min = Float::INFINITY
        global_max = -Float::INFINITY
        sorted_values.each { |x_vals|
          ds = DataSeries.new('_', x_vals)
          desc_stats = ds.descriptive_statistics
          # compute first and third quartile. Use min and max if they are nil
          # for very small data series with only one or two entries.
          q1 = desc_stats.detect { |e| '25%ile' == e[:label] }[:value] || x_vals.min
          q3 = desc_stats.detect { |e| '75%ile' == e[:label] }[:value] || x_vals.max
          iqr = (q3 - q1) * 1.5
          local_min = [x_vals.min, q1 - iqr].max
          global_min = [global_min, local_min].min
          local_max = [x_vals.max, q3 + iqr].min
          global_max = [global_max, local_max].max
        }

        {
          values: sorted_values,
          category_labels: y_sorted_keys,
          min: global_min,
          max: global_max,
          base_width: 100,
          base_height: 960,
          axis_tick_format: x_ds.axis_tick_format,
          num_box_plots: y_ds.uniq_vals_count,
          axis_scale: DataSeries.new('_', [global_min, global_max]).axis_scale(:d3)
        }
      end

      def render
        return ''  unless render?
        ca = compute_chart_attrs
        return ''  unless ca

        svg_trs = ca[:category_labels].map { |cat_label|
          %(
            <tr>
              <td style="vertical-align: middle;">#{ cat_label }</td>
              <td style="vertical-align: middle; width: 100%">
                <svg class="box" style="height: #{ ca[:base_width] }px;"></svg>
              </td>
            </tr>
          )
        }.join.html_safe
        %(
          <div id="#{ dom_id }" class="rde-chart rde-box-plot-group">
            <table>#{ svg_trs }</table>

            <script type="text/javascript">
              (function() {
                var base_width = #{ ca[:base_width] },
                    base_height = #{ ca[:base_height] },
                    margin = { top: 10, right: 40, bottom: 10, left: 40 },
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
                chart.scale(#{ ca[:axis_scale] });

                var svg = d3.select("##{ dom_id }").selectAll("svg")
                            .data(data)
                          .append("g")
                            .attr("transform", "rotate(90) translate(" + margin.left + " -" + (height + margin.bottom) + ")")
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
