# -*- coding: utf-8 -*-

class RailsDataExplorer

  # NOTE: DataSeries values are immutable once instantiated.
  #
  # Responsibilities:
  #  * Represent a data series
  #  * Compute statistics
  #  * Compute chart attributes
  #  * Cache computed properties like values, statistics
  #  * Provide modified versions of values
  #    (e.g., :limit_distinct_values, :compress_quantitative_values)
  #
  # Collaborators:
  #  * DataType
  #
  class DataSeries

    # TODO: Add concept of significant figures for rounding values when displaying them
    # http://en.wikipedia.org/wiki/Significant_figures

    attr_reader :data_type, :name, :chart_roles
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
      20
    end

    # options: :chart_roles, :data_type (all optional)
    def initialize(_name, _values, options={})
      options = { chart_roles: [], data_type: nil }.merge(options)
      @name = _name
      @values = _values
      @data_type = init_data_type(options[:data_type])
      @chart_roles = init_chart_roles(options[:chart_roles]) # after data_type!
      @options = options
    end

    # Returns descriptive_statistics as a flat Array
    # (see #values)
    def descriptive_statistics(modification = {})
      @cached_descriptive_statistics ||= {}
      @cached_descriptive_statistics[modification] ||= (
        data_type.descriptive_statistics(values(modification))
      )
    end

    # Returns descriptive_statistics as a renderable table structure
    # (see #values)
    def descriptive_statistics_table(modification = {})
      @cached_descriptive_statistics_table ||= {}
      @cached_descriptive_statistics_table[modification] ||= (
        data_type.descriptive_statistics_table(values(modification))
      )
    end

    # (see #values)
    def number_of_values(modification = {})
      @cached_number_of_values ||= {}
      @cached_number_of_values[modification] ||= (
        values(modification).length
      )
    end

    # (see #values)
    def values_summary(modification = {})
      @cached_values_summary ||= {}
      @cached_values_summary[modification] ||= (
        v = values(modification)
        if v.length < 3 || v.inspect.length < 80
          v.inspect
        else
          "[#{ v.first } ... #{ v.last }]"
        end
      )
    end

    # Returns the values for this data series with an optional modification
    # @param modification [Hash, optional] type of modification.
    # {
    #   name: :limit_distinct_values,
    #   max_num_distinct_values: 20,
    #   val_for_others: '[Other]',
    # }
    # {
    #   name: :compress_quantitative_values,
    # }
    def values(modification = {})
      @cached_values ||= {}
      @cached_values[modification] ||= (
        case modification[:name]
        when NilClass
          @values
        when :limit_distinct_values
          # Returns variant of self's values with number of distinct values limited
          # to :max_num_distinct_values. Less frequent values are mapped to
          # :val_for_others.
          # @param max_num_distinct_values [Integer, optional]
          data_type.limit_distinct_values(
            @values,
            (
              modification[:max_num_distinct_values] ||
              @options[:max_num_distinct_values] ||
              self.class.many_uniq_vals_threshold
            ),
            (
              modification[:val_for_others] ||
              @options[:val_for_others]
            )
          )
        else
          raise "Handle this modification: #{ modification.inspect }"
        end
      )
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

    # (see #values)
    def axis_tick_format(modification = {})
      data_type.axis_tick_format(values(modification))
    end

    # @param[Symbol] d3_or_vega :d3 or :vega
    def axis_scale(d3_or_vega, modification = {})
      data_type.axis_scale(self, modification, d3_or_vega)
    end

    # (see #values)
    def uniq_vals(modification = {})
      @cached_uniq_vals ||= {}
      @cached_uniq_vals[modification] ||= values(modification).uniq
    end

    # (see #values)
    def uniq_vals_count(modification = {})
      @cached_uniq_vals_count ||= {}
      @cached_uniq_vals_count[modification] ||= uniq_vals(modification).length
    end

    # (see #values)
    def min_val(modification = {})
      @cached_min_val ||= {}
      @cached_min_val[modification] ||= values(modification).compact.min
    end

    # (see #values)
    def max_val(modification = {})
      @cached_max_val ||= {}
      @cached_max_val[modification] ||= values(modification).compact.max
    end

    # (see #values)
    def dynamic_range(modification = {})
      @cached_dynamic_range ||= {}
      @cached_dynamic_range[modification] ||= (
        divisor = [min_val(modification), max_val(modification)].min.to_f
        0 == divisor ? 0.0 : max_val / divisor
      )
    end

    # (see #values)
    def has_large_dynamic_range?(modification = {})
      @cached_has_large_dynamic_range ||= {}
      @cached_has_large_dynamic_range[modification] ||= (
        dynamic_range(modification) > self.class.large_dynamic_range_threshold
      )
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
