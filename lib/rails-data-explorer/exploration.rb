class RailsDataExplorer
  class Exploration

    attr_accessor :charts, :data_container, :title

    # Initializes a new visualization.
    # @param[String] _title will be printed at top of visualization
    # @param[Array] data_container_or_array can be a number of things:
    #  * Array<Scalar> - for single data series, uni-variate options are applied.
    #  * Array<Hash> - for multiple data series, bi/multi-variate options are applied.
    #  * DataContainer - For finer grained control.
    # @param[Array<Chart, String, Symbol>, optional] chart_specs
    #  The list of charts to include. Defaults to all applicable charts for the
    #  given data_container_or_array.
    #  Charts can be provided as Array of Strings, Symbols, or Chart classes
    #  (can be mixed).
    def initialize(_title, data_container_or_array, chart_specs=nil)
      @title = _title
      @data_container = initialize_data_container(data_container_or_array)
      @charts = initialize_charts(chart_specs)
    end

    def render
      r = "<h2>#{ @title }</h2>"
      r << @charts.map { |e| e.render }.join
      r.html_safe
    end

    def inspect(indent=1, recursive=1000)
      r = %(#<#{ self.class.to_s }\n)
      r << [
        "@title=#{ @title.inspect }",
      ].map { |e| "#{ '  ' * indent }#{ e }\n"}.join
      if recursive > 0
        r << %(#{ '  ' * indent }@data_container=)
        r << data_container.inspect(indent + 1, recursive - 1)
      end
      r << %(#{ '  ' * (indent-1) }>\n)
    end

  private

    def initialize_charts(chart_specs)
      if chart_specs.present?
        chart_specs.map { |chart_spec|
          case chart_spec
          when Chart
          when String, Symbol
          else
          end
        }
      else
        @data_container.available_chart_types.map { |e|
          e.send(:new, @data_container)
        }
      end
    end

    def initialize_data_container(data_container_or_array)
      case data_container_or_array
      when Array
        DataContainer.new(data_container_or_array)
      when DataContainer
        # use as is
        _data_container
      else
        raise(
          ArgumentError.new(
            "data_container_or_array must be an Array or a DataContainer, " + \
            "is #{ data_container_or_array.class.to_s }"
          )
        )
      end
    end

  end
end
