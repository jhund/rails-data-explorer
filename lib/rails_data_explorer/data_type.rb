# -*- coding: utf-8 -*-

class RailsDataExplorer

  # Responsibilities:
  #  * Represent a type of data
  #  * Determine available chart types
  #  * Compute descriptive statistics
  #  * Compute modified values
  #
  # Collaborators:
  #  * DataSeries
  #  * Chart
  #
  class DataType

    # @param[Hash, optional] constraints
    #  * :dimensions_count - how many data_series are there?
    def available_chart_types(constraints={})
      r = all_available_chart_types
      if(c = constraints.delete(:dimensions_count))
        r = r.find_all { |chart_type|
          (
            chart_type[:dimensions_count_min].nil? ||
            (chart_type[:dimensions_count_min] <= c)
          ) && (
            chart_type[:dimensions_count_max].nil? ||
            (chart_type[:dimensions_count_max] >= c)
          )
        }
      end
      if(c = constraints.delete(:chart_roles))
        # c = { ChartClass => [:x, :y], ... }
        r = r.find_all { |chart_type|
          c[chart_type[:chart_class]].nil? ||
          (c[chart_type[:chart_class]] & chart_type[:chart_roles]).any?
        }
      end
      # check for any unhandled options
      if constraints.any?
        raise "Unhandled constraints: #{ constraints.inspect }"
      end
      r
    end

  end
end
