# See this project for code to compute chi_square and contingency_coefficient
# https://github.com/bioruby/bioruby/blob/master/lib/bio/util/contingency_table.rb
class RailsDataExplorer
  class Chart
    class ContingencyTable < Chart

      def initialize(_data_set, options = {})
        @data_set = _data_set
        @options = {}.merge(options)
      end

      def compute_chart_attrs
        x_candidates = @data_set.data_series.find_all { |ds|
          (ds.chart_roles[Chart::ContingencyTable] & [:x, :any]).any?
        }
        y_candidates = @data_set.data_series.find_all { |ds|
          (ds.chart_roles[Chart::ContingencyTable] & [:y, :any]).any?
        }

        x_ds = x_candidates.first
        y_ds = (y_candidates - [x_ds]).first

        # Compute @observed_vals, @expected_vals, etc.
        compute_contingency_and_chi_squared!(x_ds, y_ds)

        x_sorted_keys = x_ds.uniq_vals.sort { |a,b|
          @observed_vals[b][:_sum] <=> @observed_vals[a][:_sum]
        }
        y_sorted_keys = y_ds.uniq_vals.sort { |a,b|
          @observed_vals[:_sum][b] <=> @observed_vals[:_sum][a]
        }

        ca = case @data_set.dimensions_count
        when 2
          # Table
          OpenStruct.new(
            # Top header row
            :rows => [
              OpenStruct.new(
                :css_class => 'rde-column_header',
                :tag => :tr,
                :cells => [
                  OpenStruct.new(:tag => :th, :value => '')
                ] +
                x_sorted_keys.map { |x_val|
                  OpenStruct.new(:tag => :th, :value => x_val)
                } +
                [OpenStruct.new(:tag => :th, :value => 'Totals')]
              )
            ] +
            # Data rows
            y_sorted_keys.map { |y_val|
              OpenStruct.new(
                :css_class => 'rde-data_row',
                :tag => :tr,
                :cells => [
                  OpenStruct.new(:tag => :th, :value => y_val, :css_class => 'rde-row_header')
                ] +
                x_sorted_keys.map { |x_val|
                  OpenStruct.new(
                    :tag => :td,
                    :value => @observed_vals[x_val][y_val],
                    :css_class => 'rde-numerical',
                    :title => "Expected value: #{ number_with_precision(@expected_vals[x_val][y_val]) }",
                    :style => "color: #{ @delta_attrs[x_val][y_val][:color] };",
                  )
                } +
                [OpenStruct.new(:tag => :th, :value => @observed_vals[:_sum][y_val])]
              )
            } +
            # Footer row
            [
              OpenStruct.new(
                :css_class => 'rde-column_header',
                :tag => :tr,
                :cells => [
                  OpenStruct.new(:tag => :th, :value => 'Totals', :css_class => 'rde-row_header')
                ] +
                x_sorted_keys.map { |x_val|
                  OpenStruct.new(:tag => :th, :value => @observed_vals[x_val][:_sum])
                } +
                [OpenStruct.new(:tag => :th, :value => @observed_vals[:_sum][:_sum])]
              )
            ]
          )
        else
          raise(ArgumentError.new("Exactly two data series required for contingency table."))
        end
        ca
      end

      def render
        return ''  unless render?
        ca = compute_chart_attrs
        content_tag(:div, :class => 'rde-chart rde-contingency-table', :id => dom_id) do
          content_tag(:h3, "Contingency Table", :class => 'rde-chart-title') +
          render_html_table(ca)
        end +
        content_tag(:p, @conclusion)
      end

      def render?
        # http://en.wikipedia.org/wiki/Pearson's_chi-squared_test#Assumptions
        true
      end

    private

      # Computes @observed_vals, @expected_vals, @chi_squared, etc.
      # @param[DataSeries] x_ds
      # @param[DataSeries] y_ds
      def compute_contingency_and_chi_squared!(x_ds, y_ds)
        # Compute the observed values table
        @observed_vals = { :_sum => { :_sum => 0 } }
        x_ds.uniq_vals.each { |x_val|
          @observed_vals[x_val] = {}
          @observed_vals[x_val][:_sum] = 0
          y_ds.uniq_vals.each { |y_val|
            @observed_vals[x_val][y_val] = 0
            @observed_vals[:_sum][y_val] = 0
          }
        }
        x_ds.values.length.times { |idx|
          x_val = x_ds.values[idx]
          y_val = y_ds.values[idx]
          @observed_vals[x_val][y_val] += 1
          @observed_vals[:_sum][y_val] += 1
          @observed_vals[x_val][:_sum] += 1
          @observed_vals[:_sum][:_sum] += 1
        }
        # Compute degrees of freedom
        @degrees_of_freedom = (x_ds.uniq_vals_count - 1) * (y_ds.uniq_vals_count - 1)
        # Compute the expected values table
        @expected_vals = {}
        x_ds.uniq_vals.each { |x_val|
          @expected_vals[x_val] = {}
          y_ds.uniq_vals.each { |y_val|
            @expected_vals[x_val][y_val] = (
              @observed_vals[:_sum][y_val] * @observed_vals[x_val][:_sum]
            ) / (@observed_vals[:_sum][:_sum]).to_f
          }
        }
        # Compute Chi squared
        @chi_squared = 0
        x_ds.uniq_vals.each { |x_val|
          y_ds.uniq_vals.each { |y_val|
            @chi_squared += (
              (@observed_vals[x_val][y_val] - @expected_vals[x_val][y_val]) ** 2
            ) / @expected_vals[x_val][y_val]
          }
        }
        # Compute deltas
        @delta_attrs = {}
        color_scale = RailsDataExplorer::Utils::ColorScale.new
        x_ds.uniq_vals.each { |x_val|
          @delta_attrs[x_val] = {}
          y_ds.uniq_vals.each { |y_val|
            delta = @observed_vals[x_val][y_val] - @expected_vals[x_val][y_val]
            delta_factor = delta / @expected_vals[x_val][y_val].to_f
            @delta_attrs[x_val][y_val] = {
              :expected => @expected_vals[x_val][y_val],
              :color => color_scale.compute(delta_factor),
              :delta => delta,
              :delta_factor => delta_factor,
            }
          }
        }
        # Compute probability of observing a sample statistic as extreme as the
        # observed test statistic.
        @p_value = 1 - Distribution::ChiSquare.cdf(@chi_squared, @degrees_of_freedom)
        # Set significance_level
        @significance_level = 0.05
        # Compute conclusion
        @conclusion = %(<a href="http://en.wikipedia.org/wiki/Pearson%27s_chi-squared_test#Test_of_independence">Pearson chi squared test of independence</a> suggests that )
        @conclusion << if @p_value <= @significance_level
          "#{ x_ds.name } and #{ y_ds.name } are dependent variables (p_value: #{ number_with_precision(@p_value) })"
        else
          "#{ x_ds.name } and #{ y_ds.name } are independent variables (p_value: #{ number_with_precision(@p_value) })"
        end
        @conclusion = @conclusion.html_safe
      end
    end
  end
end
