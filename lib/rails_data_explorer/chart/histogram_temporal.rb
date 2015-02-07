# -*- coding: utf-8 -*-

class RailsDataExplorer
  class Chart

    # Responsibilities:
    #  * Render a histogram for univariate analysis of a temporal data series.
    #
    # Collaborators:
    #  * DataSet
    #
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
        histogram_values_ds = DataSeries.new('_', h.values)
        y_scale_type = histogram_values_ds.axis_scale(:vega)
        bar_y2_val = 'log' == y_scale_type ? histogram_values_ds.min_val / 10.0 : 0
        width = 960
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
          y_scale_type: y_scale_type,
          y_scale_domain: [bar_y2_val, histogram_values_ds.max_val],
          bar_y2_val: bar_y2_val,
          css_class: 'rde-histogram-temporal',
        }
      end

    end
  end
end
