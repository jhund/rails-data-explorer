# Container for data series
class RailsDataExplorer
  class DataContainer

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
    def initialize(values_or_data_series)
      @data_series = initialize_data_series(values_or_data_series)
      validate_data_series
    end

    def initialize_data_series(values_or_data_series)
      case values_or_data_series.first
      when ActiveSupport::TimeWithZone, DateTime, Numeric, NilClass, String, Symbol
        # Array of scalar values, convert to single data series
        [DataSeries.new('', values_or_data_series)]
      when Hash
        # Array of Hashes, convert to multiple data series
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
      # all elements in a series are of same type
    end

    def cardinality
      @data_series.length
    end

    def available_chart_types
      case cardinality
      when 0
        raise(ArgumentError.new("No data given"))
      when 1
        # charts for a single data series, use that series' available_chart_types
        @data_series.first.available_chart_types(cardinality: 1).map { |e| e[:chart_class] }
      when 2
        # charts for two data series
        # find intersection of all available chart types
        r = @data_series.inject(nil) { |m,ds|
          constraints = { cardinality: 2, chart_roles: ds.chart_roles }
          # initialize m with first data series
          m = ds.available_chart_types(constraints).map { |e| e[:chart_class] }  if m.nil?
          # find intersection of all available_chart_types
          m = ds.available_chart_types(constraints).map { |e| e[:chart_class] } & m
          m
        }
        r
      when 3
        # charts for two data series
        # find intersection of all available chart types
        r = @data_series.inject(nil) { |m,ds|
          constraints = { cardinality: 3, chart_roles: ds.chart_roles }
          # initialize m with first data series
          m = ds.available_chart_types(constraints).map { |e| e[:chart_class] }  if m.nil?
          # find intersection of all available_chart_types
          m = ds.available_chart_types(constraints).map { |e| e[:chart_class] } & m
          m
        }
        r
      else
        # charts for multiple data series
      end
    end

    def descriptive_statistics
      case cardinality
      when 0
        raise(ArgumentError.new("No data given"))
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
        "@cardinality=#{ cardinality }",
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
