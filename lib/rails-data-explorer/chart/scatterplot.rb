class RailsDataExplorer
  class Chart
    class Scatterplot < Chart

      def initialize(_data_set, options = {})
        @data_set = _data_set
        @options = {}.merge(options)
      end

      def compute_chart_attrs
        x_candidates = @data_set.data_series.find_all { |ds|
          (ds.chart_roles[Chart::Scatterplot] & [:x, :any]).any?
        }
        y_candidates = @data_set.data_series.find_all { |ds|
          (ds.chart_roles[Chart::Scatterplot] & [:y, :any]).any?
        }
        color_candidates = @data_set.data_series.find_all { |ds|
          (ds.chart_roles[Chart::Scatterplot] & [:color, :any]).any?
        }
        size_candidates = @data_set.data_series.find_all { |ds|
          (ds.chart_roles[Chart::Scatterplot] & [:size, :any]).any?
        }

        x_ds = x_candidates.first
        y_ds = (y_candidates - [x_ds]).first
        color_ds = (color_candidates - [x_ds, y_ds]).first
        size_ds = (size_candidates - [x_ds, y_ds, color_ds]).first
        return false  if x_ds.nil? || y_ds.nil?

        ca = case @data_set.dimensions_count
        when 0,1
          raise(ArgumentError.new("At least two data series required for scatterplot, only #{ @data_set.dimensions_count } given"))
        when 2
          key = ''
          values_hash = x_ds.values.length.times.map { |idx|
            r = { x: x_ds.values[idx], y: y_ds.values[idx] }
            r[:color] = color_ds.values[idx]  if color_ds
            r
          }
          {
            values: [ { key: key, values: values_hash } ],
            x_axis_label: x_ds.name,
            x_axis_tick_format: x_ds.axis_tick_format,
            y_axis_label: y_ds.name,
            y_axis_tick_format: y_ds.axis_tick_format,
          }
        when 3
          visual_attr_ds = color_ds || size_ds
          raise "No visual_attr_ds given"  if visual_attr_ds.nil?
          data_series_hash = visual_attr_ds.values.uniq.inject({}) { |m,visual_attr|
            m[visual_attr] = []
            m
          }
          x_ds.values.length.times.each { |idx|
            data_series_hash[visual_attr_ds.values[idx]] << { x: x_ds.values[idx], y: y_ds.values[idx] }
          }
          {
            values: data_series_hash.map { |k,v| { key: k, values: v } },
            x_axis_label: x_ds.name,
            x_axis_tick_format: x_ds.axis_tick_format,
            y_axis_label: y_ds.name,
            y_axis_tick_format: y_ds.axis_tick_format,
          }
        else
        end
        ca
      end

      def render
        return ''  unless render?
        ca = compute_chart_attrs
        return ''  unless ca

        %(
          <div class="rde-chart rde-scatterplot">
            <h3 class="rde-chart-title">Scatterplot</h3>
            <div id="#{ dom_id }", style="height: 400px;">
              <svg></svg>
            </div>
            <script type="text/javascript">
              (function() {
                var data = #{ ca[:values].to_json };

                nv.addGraph(function() {
                  var chart = nv.models.scatterChart()
                                .showDistX(true)
                                .showDistY(true)
                                .useVoronoi(true)
                                .color(d3.scale.category10().range())
                                .transitionDuration(300)
                                ;

                  chart.xAxis.tickFormat(#{ ca[:x_axis_tick_format] })
                             .axisLabel('#{ ca[:x_axis_label] }')
                             ;

                  chart.yAxis.tickFormat(#{ ca[:y_axis_tick_format] })
                             .axisLabel('#{ ca[:y_axis_label] }')
                             ;

                  chart.tooltipContent(function(key) {
                      return key;
                  });

                  d3.select('##{ dom_id } svg')
                      .datum(data)
                      .call(chart);

                  nv.utils.windowResize(chart.update);

                  chart.dispatch.on('stateChange', function(e) { ('New State:', JSON.stringify(e)); });

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
