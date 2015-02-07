# -*- coding: utf-8 -*-

class RailsDataExplorer
  module Utils

    # Responsibilities:
    #  * Format values in data series and individual data
    #
    # Good resource on significant figures:
    # * http://www.edu.pe.ca/gray/class_pages/krcutcliffe/physics521/sigfigs/sigfigRULES.htm
    # * http://en.wikipedia.org/wiki/Significant_figures
    class ValueFormatter

      attr_accessor :d3_format, :ruby_formatter, :significant_figures

      # @param[Object] context
      def initialize(context)
        case context
        when DataSeries
          initialize_from_data_series(context)
        when Hash
          initialize_from_options(context)
        when Numeric
          initialize_from_single_value(context)
        else
          raise "Handle this context: #{ context.inspect }"
        end
      end

    private

      def initialize_from_data_series(data_series)
      end

      def initialize_from_options(options)
        @d3_format = options[:d3_format]
        @significant_figures = options[:significant_figures]
        @ruby_formatter = options[:ruby_formatter]
      end

      def initialize_from_single_value(options)
      end

    end
  end
end
