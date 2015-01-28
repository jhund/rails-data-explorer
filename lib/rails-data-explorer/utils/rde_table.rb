# Defines classes to describe tables:
#     rde_table.rows
#       rde_row.css_class
#       rde_row.tag
#       rde_row.cells
#         rde_cell.css_class
#         rde_cell.ruby_formatter
#         rde_cell.style
#         rde_cell.tag
#         rde_cell.title
#         rde_cell.value

class RailsDataExplorer
  module Utils

    class RdeTable

      attr_accessor :rows

      def initialize(rows)
        @rows = rows
      end

    end


    class RdeTableRow

      attr_accessor :cells
      attr_accessor :css_class
      attr_accessor :tag

      def initialize(tag, cells, opts = {})
        @tag = tag
        @cells =cells
        @css_class = opts[:css_class]
      end

    end

    class RdeTableCell

      attr_accessor :tag
      attr_accessor :value
      attr_accessor :css_class
      attr_accessor :ruby_formatter
      attr_accessor :style
      attr_accessor :title

      def initialize(tag, value, opts = {})
        @tag = tag
        @value = value
        @css_class = opts[:css_class]
        @ruby_formatter = opts[:ruby_formatter]
        @style = opts[:style]
        @title = opts[:title]
      end

    end

  end
end
