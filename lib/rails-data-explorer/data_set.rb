# Container for data series
class RailsDataExplorer
  class DataSet

    attr_reader :data_series

    # @param[Array<Numeric, String, Symbol, Nil, Hash, DataSeries>] values_or_data_series
    #  Array can contain the following:
    #  * Numeric, String, Symbol, Nil - for a single data series
    #  * Hash - for multiple data series with the following keys:
    #    * :name - name for the series as String
    #    * :values - scalar values as array
    #    * :chart_roles [Array<Symbol>, optional] - what to use this series for. possible values: :x, :y, :color
    #    * :data_type (optional) - :quantitative, :categorical, :temporal
    #  * DataSeries
    # @param[String] exploration_title used as fall back for data series name
    def initialize(values_or_data_series, exploration_title)
      @data_series = initialize_data_series(values_or_data_series, exploration_title)
      validate_data_series
    end

    def initialize_data_series(values_or_data_series, exploration_title)
      case values_or_data_series.first
      when ActiveSupport::TimeWithZone, DateTime, Numeric, NilClass, String, Symbol
        # Array of scalar values, convert to single data series
        [DataSeries.new(exploration_title, values_or_data_series)]
      when Hash
        # Array of Hashes, convert each key/val pair to a data series
        values_or_data_series.map { |data_series_attrs|
          DataSeries.new(
            data_series_attrs.delete(:name),
            data_series_attrs.delete(:values),
            data_series_attrs # pass remaining attrs as options
          )
        }
      when DataSeries
        # return as is
        values_or_data_series
      else
        raise(
          ArgumentError.new(
            "Invalid datum. Only Hash, Numeric, String, Symbol, and Nil are allowed. " + \
            "Found #{ values_or_data_series.first.class.to_s }."
          )
        )
      end
    end

    def validate_data_series
      # all series have same size
      unless 1 == @data_series.map { |e| e.values.length }.uniq.length
        raise(ArgumentError.new("All data series must have same length."))
      end
      # presence of at least one data_series
      if 0 == dimensions_count
        raise(ArgumentError.new("Please provide at least 1 data series."))
      end
      # TODO: all elements in a series are of same type
    end

    def dimensions_count
      @data_series.length
    end

    def available_chart_types
      case dimensions_count
      when 0
        # invalid, handled in validate_data_series
      when 1
        # charts for a single data series, use that series' available_chart_types
        @data_series.first.available_chart_types(dimensions_count: 1).map { |e| e[:chart_class] }
      else
        # TODO: define on each chart type which chart_roles are required.
        # Then use only charts for which all roles are filled.
        # charts for two data series
        # find intersection of all available chart types
        r = @data_series.inject(nil) { |m,ds|
          constraints = { dimensions_count: dimensions_count, chart_roles: ds.chart_roles }
          # initialize m with first data series
          m = ds.available_chart_types(constraints).map { |e| e[:chart_class] }  if m.nil?
          # find intersection of all available_chart_types
          m = ds.available_chart_types(constraints).map { |e| e[:chart_class] } & m
          m
        }
        r
      end
    end

    def descriptive_statistics
      case dimensions_count
      when 0
        # invalid, handled in validate_data_series
      when 1
        # charts for a single data series, use that series' descriptive_statistics
        @data_series.first.descriptive_statistics
      when 2
        # charts for two data series
      else
        # charts for multiple data series
      end
    end

    def inspect(indent=1, recursive=1000)
      r = %(#<#{ self.class.to_s }\n)
      r << [
        "@dimensions_count=#{ dimensions_count }",
      ].map { |e| "#{ '  ' * indent }#{ e }\n"}.join
      if recursive > 0
        # data_series
        r << %(#{ '  ' * indent }@data_series=[\n)
        data_series.each do |e|
          r << "#{ '  ' * (indent + 1) }"
          r << e.inspect(indent + 2, recursive - 1)
        end
        r << "#{ '  ' * indent }]\n"
        # available_chart_types
        r << %(#{ '  ' * indent }@available_chart_types=[\n)
        available_chart_types.each do |e|
          r << "#{ '  ' * (indent + 1) }#{ e.inspect }\n"
        end
        r << "#{ '  ' * indent }]\n"
      end
      r << %(#{ '  ' * (indent-1) }>\n)
    end

  end
end
