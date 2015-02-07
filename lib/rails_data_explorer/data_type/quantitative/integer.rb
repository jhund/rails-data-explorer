# -*- coding: utf-8 -*-

class RailsDataExplorer
  class DataType
    class Quantitative

      # Responsibilities:
      #  * Provide methods for integer quantitative data type.
      #
      # Collaborators:
      #  * DataSet
      #
      class Integer < Quantitative

        def axis_tick_format(values)
          "d3.format('r')"
        end

      end
    end
  end
end
