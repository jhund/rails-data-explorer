# TODO: could I use histogram_quantitative instead and just tweak the tick mark format?
class RailsDataExplorer
  class Chart
    class HistogramTemporal < HistogramQuantitative

      def compute_chart_attrs
        x_ds = @data_set.data_series.first
        return false  if x_ds.nil?

        # compute histogram
        h = x_ds.values.inject(Hash.new(0)) { |m,e|
          # Round to day
          key = e.nil? ? nil : (e.beginning_of_day).to_i * 1000
          m[key] += 1
          m
        }
        width = 800
        {
          values: h.map { |k,v| { x: k, y: v } },
          width: width,
          x_axis_label: x_ds.name,
          x_axis_tick_format: x_ds.axis_tick_format,
          x_scale_type: 'time',
          x_scale_nice: "'day'",
          bar_width: 2,
          y_axis_label: 'Frequency',
          y_axis_tick_format: "d3.format('r')",
        }
      end

    end
  end
end
