class RailsDataExplorer
  class Exploration

    attr_accessor :output_buffer # required for content_tag
    include ActionView::Helpers::TagHelper

    attr_accessor :charts, :data_set, :title

    # Initializes a new visualization.
    # @param[String] _title will be printed at top of visualization
    # @param[Array] data_set_or_array can be a number of things:
    #  * Array<Scalar> - for single data series, uni-variate options are applied.
    #  * Array<Hash> - for multiple data series, bi/multi-variate options are applied.
    #  * DataSet - For finer grained control.
    # @param[Array<Chart, String, Symbol>, optional] chart_specs
    #  The list of charts to include. Defaults to all applicable charts for the
    #  given data_set_or_array.
    #  Charts can be provided as Array of Strings, Symbols, or Chart classes
    #  (can be mixed).
    def initialize(_title, data_set_or_array, chart_specs=nil)
      @title = _title
      @data_set = initialize_data_set(data_set_or_array)
      @charts = initialize_charts(chart_specs)
    end

    def render
      content_tag(:div, class: 'rde-exploration panel panel-default', id: dom_id) do
        content_tag(:div, class: 'panel-heading') do
          %(<span style="float: right;"><a href="#rails_data_explorer-toc">Top</a></span>).html_safe +
          content_tag(:h2, @title, class: 'rde-exploration-title panel-title')
        end +
        content_tag(:div, class: 'panel-body') do
          if @charts.any?
            @charts.map { |e| e.render }.join.html_safe
          else
            "No charts are available for this combination of data series."
          end
        end
      end.html_safe
    end

    def dom_id
      "rde-exploration-#{ object_id }"
    end

    def inspect(indent=1, recursive=1000)
      r = %(#<#{ self.class.to_s }\n)
      r << [
        "@title=#{ @title.inspect }",
      ].map { |e| "#{ '  ' * indent }#{ e }\n"}.join
      if recursive > 0
        r << %(#{ '  ' * indent }@data_set=)
        r << data_set.inspect(indent + 1, recursive - 1)
      end
      r << %(#{ '  ' * (indent-1) }>\n)
    end

    def type_of_analysis
      case @data_set.dimensions_count
      when 0
        '[No data given]'
      when 1
        'Univariate'
      when 2
        'Bivariate'
      else
        'Multivariate'
      end
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
        @data_set.available_chart_types.map { |e|
          e.send(:new, @data_set)
        }
      end
    end

    def initialize_data_set(data_set_or_array)
      case data_set_or_array
      when Array
        DataSet.new(data_set_or_array, @title)
      when DataSet
        # use as is
        _data_set
      else
        raise(
          ArgumentError.new(
            "data_set_or_array must be an Array or a DataSet, " + \
            "is #{ data_set_or_array.class.to_s }"
          )
        )
      end
    end

  end
end
