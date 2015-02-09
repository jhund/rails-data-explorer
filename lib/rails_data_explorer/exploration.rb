# -*- coding: utf-8 -*-

class RailsDataExplorer

  # Responsibilities:
  #  * Represent and initialize a data exploration
  #  * Initialize and render self (including charts)
  #
  # Collaborators:
  #  * DataSet
  #  * Chart
  #
  class Exploration

    attr_accessor :charts, :data_set, :title

    delegate :data_series_names, to: :data_set, prefix: false
    delegate :number_of_values, to: :data_set, prefix: false

    # Computes a dom_id for data_series_names
    # @param data_series_names [Array<String>]
    # @return [String]
    def self.compute_dom_id(data_series_names)
      "rde-exploration-#{ data_series_names.sort.map { |e| e.parameterize('') }.join('-') }"
    end

    # Initializes a new visualization.
    # @param _title [String] will be printed at top of visualization
    # @param data_set_or_array [Array] can be a number of things:
    #  * Array<Scalar> - for single data series, uni-variate options are applied.
    #  * Array<Hash> - for multiple data series, bi/multi-variate options are applied.
    #  * DataSet - For finer grained control.
    # @param render_charts [Boolean] set to true to render charts for this exploration
    # @param chart_specs [Array<Chart, String, Symbol>, optional]
    #  The list of charts to include. Defaults to all applicable charts for the
    #  given data_set_or_array.
    #  Charts can be provided as Array of Strings, Symbols, or Chart classes
    #  (can be mixed).
    def initialize(_title, data_set_or_array, render_charts, chart_specs=nil)
      @title = _title
      @data_set = initialize_data_set(data_set_or_array)
      @render_charts = render_charts
      @charts = initialize_charts(chart_specs)
    end

    # Returns true if charts for this exploration are to be rendered.
    def render_charts?
      @render_charts
    end

    def dom_id
      self.class.compute_dom_id(data_series_names)
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
        raise "Handle chart_specs: #{ chart_specs.inspect }"
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
        data_set_or_array
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
