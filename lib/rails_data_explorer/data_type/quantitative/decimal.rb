# -*- coding: utf-8 -*-

class RailsDataExplorer
  class DataType
    class Quantitative

      # Responsibilities:
      #  * Provide methods for decimal quantitative data type.
      #
      # Collaborators:
      #  * DataSet
      #
      class Decimal < Quantitative

        def axis_tick_format(values)
          "d3.format('.02f')"
        end

      end
    end
  end
end
