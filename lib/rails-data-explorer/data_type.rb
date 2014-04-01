class RailsDataExplorer
  class DataType

    # @param[Hash, optional] constraints
    #  * :cardinality - how many data_series are there?
    def self.available_chart_types(constraints={})
      r = all_available_chart_types
      if(c = constraints.delete(:cardinality))
        r = r.find_all { |chart_type|
          (
            chart_type[:cardinality_min].nil? ||
            (chart_type[:cardinality_min] <= c)
          ) && (
            chart_type[:cardinality_max].nil? ||
            (chart_type[:cardinality_max] >= c)
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
