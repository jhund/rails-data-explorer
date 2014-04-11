class RailsDataExplorer
  class Chart
    class StackedBarChartCategoricalPercent < Chart

      def initialize(_data_container, options = {})
        @data_container = _data_container
        @options = {}.merge(options)
      end

      def compute_chart_attrs
        x_candidates = @data_container.data_series.find_all { |ds|
          (ds.chart_roles[Chart::ContingencyTable] & [:x, :any]).any?
        }.sort { |a,b| b.values.uniq.length <=> a.values.uniq.length }
        y_candidates = @data_container.data_series.find_all { |ds|
          (ds.chart_roles[Chart::ContingencyTable] & [:y, :any]).any?
        }

        x_ds = x_candidates.first
        y_ds = (y_candidates - [x_ds]).first

        # initialize data_matrix
        data_matrix = { :_sum => { :_sum => 0 } }
        x_ds.values.uniq.each { |x_val|
          data_matrix[x_val] = {}
          data_matrix[x_val][:_sum] = 0
          y_ds.values.uniq.each { |y_val|
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

        x_sorted_keys = x_ds.values.uniq.sort { |a,b|
          data_matrix[b][:_sum] <=> data_matrix[a][:_sum]
        }
        y_sorted_keys = y_ds.values.uniq.sort { |a,b|
          data_matrix[:_sum][b] <=> data_matrix[:_sum][a]
        }

        values = case @data_container.dimensions_count
        when 2
          y_sorted_keys.map { |y_val|
            {
              key: y_val,
              values: x_sorted_keys.map { |x_val|
                {
                  x: x_val,
                  y: (data_matrix[x_val][y_val] / data_matrix[x_val][:_sum].to_f) }
              }
            }
          }
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
        %(
          <div class="rde-chart rde-bar-chart">
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
