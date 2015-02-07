class RailsDataExplorer
  class DataType
    class Quantitative
      class Decimal < Quantitative

        def axis_tick_format(values)
          "d3.format('.02f')"
        end

      end
    end
  end
end
