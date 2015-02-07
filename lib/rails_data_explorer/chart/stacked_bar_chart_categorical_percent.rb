# -*- coding: utf-8 -*-

class RailsDataExplorer
  class Chart

    # Responsibilities:
    #  * Render a stacked bar chart for bivariate analysis of two categorical
    #    data series. Renders percentage distribution of y-data series.
    #
    # Collaborators:
    #  * DataSet
    #
    class StackedBarChartCategoricalPercent < StackedBarChartCategorical

      # Override this method to change how the y value is computed. E.g., to
      # change from absolute values to percentages.
      def compute_y_value(data_matrix, x_val, y_val)
        (data_matrix[x_val][y_val] / data_matrix[x_val][:_sum].to_f) * 100
      end

      # @param y_ds_name [String] name of the y data series
      def compute_y_axis_label(y_ds_name)
        "#{ y_ds_name } distribution [%]"
      end

    end
  end
end
