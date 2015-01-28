class RailsDataExplorer
  class DataSeries

    # TODO: Add concept of significant figures for rounding values when displaying them
    # http://en.wikipedia.org/wiki/Significant_figures

    attr_reader :data_type, :name, :values, :chart_roles
    delegate :available_chart_types, to: :data_type, prefix: false
    delegate :available_chart_roles, to: :data_type, prefix: false

    # Any data series with a dynamic range greater than this is considered
    # having a large dynamic range
    # We consider dynamic range the ratio between the largest and the smallest value.
    def self.large_dynamic_range_threshold
      10000.0
    end

    # Any data series with more than this uniq vals is considered having many
    # uniq values.
    def self.many_uniq_vals_threshold
      30
    end

    # options: :chart_roles, :data_type (all optional)
    def initialize(_name, _values, options={})
      options = { chart_roles: [], data_type: nil }.merge(options)
      @name = _name
      @values = _values
      @data_type = init_data_type(options[:data_type])
      @chart_roles = init_chart_roles(options[:chart_roles]) # after data_type!
    end

    # Returns descriptive_statistics as a flat Array
    def descriptive_statistics
      @data_type.descriptive_statistics(values)
    end

    # Returns descriptive_statistics as a renderable table structure
    def descriptive_statistics_table
      @data_type.descriptive_statistics_table(values)
    end

    def values_summary
      if values.length < 3 || values.inspect.length < 80
        values.inspect
      else
        "[#{ values.first } ... #{ values.last }]"
      end
    end

    def inspect(indent=1, recursive=1000)
      r = %(#<#{ self.class.to_s }\n)
      r << [
        "@name=#{ name.inspect }",
        "@data_type=#{ data_type.inspect }",
        "@chart_roles=#{ chart_roles.inspect }",
        "@values=<count: #{ values.count }, items: #{ values_summary }>",
      ].map { |e| "#{ '  ' * indent }#{ e }\n"}.join
      if recursive > 0
        # nothing to recurse
      end
      r << %(#{ '  ' * (indent-1) }>\n)
    end

    def axis_tick_format
      data_type.axis_tick_format(values)
    end

    # @param[Symbol] d3_or_vega :d3 or :vega
    def axis_scale(d3_or_vega)
      data_type.axis_scale(self, d3_or_vega)
    end

    def uniq_vals
      @uniq_vals ||= values.uniq
    end

    def uniq_vals_count
      @uniq_vals_count ||= uniq_vals.length
    end

    def min_val
      @min_val ||= values.compact.min
    end

    def max_val
      @max_val ||= values.compact.max
    end

    # Used to decide whether we can render certain chart types
    def has_many_uniq_vals?
      uniq_vals_count > self.class.many_uniq_vals_threshold
    end

    def dynamic_range
      max_val / [min_val, max_val].min.to_f
    end

    def has_large_dynamic_range?
      dynamic_range > self.class.large_dynamic_range_threshold
    end

    def label_sorter(label_val_key, value_sorter)
      data_type.label_sorter(label_val_key, self, value_sorter)
    end

  private

    # @param[Array<Symbol>] chart_role_overrides, :x, :y, :color
    # @return[Hash] keys are chart_classes, and values are arrays with roles
    def init_chart_roles(chart_role_overrides)
      r = if chart_role_overrides.any?
        available_chart_types.inject(Hash.new([])) { |m,chart_type|
          subset = chart_type[:chart_roles] & chart_role_overrides
          next m if subset.empty?
          m[chart_type[:chart_class]] += subset
          m[chart_type[:chart_class]].uniq!
          m
        }
      else
        available_chart_types.inject(Hash.new([])) { |m,chart_type|
          m[chart_type[:chart_class]] += chart_type[:chart_roles]
          m[chart_type[:chart_class]].uniq!
          m
        }
      end
      r.freeze
    end

    def init_data_type(data_type_override)
      if data_type_override.nil?
        first_value = values.detect { |e| !e.nil? }
        case first_value
        when Integer, Bignum, Fixnum
          DataType::Quantitative::Integer.new
        when Float
          DataType::Quantitative::Decimal.new
        when String
          DataType::Categorical.new
        when Time, DateTime, ActiveSupport::TimeWithZone
          DataType::Quantitative::Temporal.new
        else
          raise(ArgumentError.new("Can't infer data type for value: #{ values.first.class.inspect }"))
        end
      else
        data_type_override
      end
    end

  end
end
