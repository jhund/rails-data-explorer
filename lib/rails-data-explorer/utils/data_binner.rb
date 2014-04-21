# Convert quantitative data to categorical data.
# http://saedsayad.com/binning.htm
# E.g., ages in years to 5 groups:
# * < 10
# * 11 - 20
# * 21 - 30
# * 31 - 40
# * > 40
class RailsDataExplorer
  module Utils
    class DataBinner

      def initialize(*args)
        @max = -Float::INFINITY
        @bin_specs = [*args].compact.uniq.sort.map { |e|
          case e
          when Numeric
            @max = [@max, e].max
            { :label => "#{ e.to_s } or less", :lte => e }
          else
            raise "Handle this bin_spec: #{ e.inspect }"
          end
        }
        @bin_specs << { :label => "> #{ @max }", :gt => @max }
      end

      def bin(value)
        unless value.is_a?(Numeric)
          raise(ArgumentError.new("Wrong type of value, numeric expected, got: #{ value.inspect }"))
        end
        bin = @bin_specs.detect { |bs|
          (bs[:lte] && value <= bs[:lte]) || (bs[:gt] && value > bs[:gt])
        }
        bin[:label]
      end

    end
  end
end
