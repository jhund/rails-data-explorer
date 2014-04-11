# http://bl.ocks.org/jensgrubert/7789216
# http://www.datavizcatalogue.com/methods/box_plot.html#.U0S8Ra1dUyE
# http://mbostock.github.io/protovis/ex/box-and-whisker.html
# http://bl.ocks.org/mbostock/4061502
# http://johan.github.io/d3/ex/box.html
class RailsDataExplorer
  class Chart
    class BoxPlotGroup < Chart

      def initialize(_data_container, options = {})
        @data_container = _data_container
        @options = {}.merge(options)
      end

      def compute_chart_attrs
      end

      def render
        return ''  unless render?
        "Box plot group"
      end

    end
  end
end
