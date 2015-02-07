class RailsDataExplorer
  class DataType
    class Quantitative
      class Integer < Quantitative

        def axis_tick_format(values)
          "d3.format('r')"
        end

      end
    end
  end
end
