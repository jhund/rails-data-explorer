class RailsDataExplorer
  class Chart

    include ActionView::Helpers::NumberHelper
    attr_accessor :output_buffer # required for content_tag
    include ActionView::Helpers::TagHelper

    def dom_id
      "rde-chart-#{ object_id }"
    end

    # Returns true if this chart will be rendered. Sometimes we can't make that
    # decision until render time. Override this method in sub classes, e.g.,
    # to avoid rendering ParallelCoordinates when all data series are categorical.
    def render?
      true
    end

  protected

    # Renders an HTML table
    # @param[OpenStruct, Struct] table_struct
    def render_html_table(table_struct)
      content_tag(:table, :class => 'table rde-table') do
        table_struct.rows.map { |row|
          content_tag(row.tag, :class => row.css_class) do
            row.cells.map { |cell|
              if cell.ruby_formatter
                content_tag(
                  cell.tag,
                  instance_exec(cell.value, &cell.ruby_formatter),
                  :class => cell.css_class,
                  :title => cell.title,
                  :style => cell.style,
                )
              else
                content_tag(
                  cell.tag,
                  cell.value,
                  :class => cell.css_class,
                  :title => cell.title,
                  :style => cell.style,
                )
              end
            }.join.html_safe
          end
        }.join.html_safe
      end
    end

  end
end
