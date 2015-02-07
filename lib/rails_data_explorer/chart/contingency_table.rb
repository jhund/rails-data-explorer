# -*- coding: utf-8 -*-

class RailsDataExplorer
  class Chart

    # Contingency table and chi squared test are great tools for interpreting
    # A/B tests.
    #
    # Responsibilities:
    #  * Render a contingency table for bivariate analysis of two categorical
    #    data series.
    #
    # Collaborators:
    #  * DataSet
    #
    # See this project for code to compute chi_square and contingency_coefficient
    # https://github.com/bioruby/bioruby/blob/master/lib/bio/util/contingency_table.rb
    #
    # Resources for Chi Squared Test
    # * http://www.quora.com/What-is-the-most-intuitive-explanation-for-the-chi-square-test
    # * http://people.revoledu.com/kardi/tutorial/Questionnaire/Chi-Square%20IndependentTest.html
    # * http://stattrek.com/chi-square-test/independence.aspx?Tutorial=AP
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
        return false  if x_ds.nil? || y_ds.nil?

        # Compute @observed_vals, @expected_vals, etc.
        compute_contingency_and_chi_squared!(x_ds, y_ds)

        x_sorted_keys = x_ds.uniq_vals.sort(
          &x_ds.label_sorter(
            nil,
            lambda { |a,b| @observed_vals[b][:_sum] <=> @observed_vals[a][:_sum] }
          )
        )
        y_sorted_keys = y_ds.uniq_vals.sort(
          &y_ds.label_sorter(
            nil,
            lambda { |a,b| @observed_vals[:_sum][b] <=> @observed_vals[:_sum][a] }
          )
        )

        ca = case @data_set.dimensions_count
        when 2
          Utils::RdeTable.new(
            # Top header row
            [
              Utils::RdeTableRow.new(
                :tr,
                [Utils::RdeTableCell.new(:th, '')] +
                x_sorted_keys.map { |x_val| Utils::RdeTableCell.new(:th, x_val) } +
                [Utils::RdeTableCell.new(:th, 'Totals')],
                css_class: 'rde-column_header'
              )
            ] +
            # Data rows
            y_sorted_keys.map { |y_val|
              Utils::RdeTableRow.new(
                :tr,
                [
                  Utils::RdeTableCell.new(:th, y_val, css_class: 'rde-row_header')
                ] +
                x_sorted_keys.map { |x_val|
                  Utils::RdeTableCell.new(
                    :td,
                    @observed_vals[x_val][y_val],
                    css_class: 'rde-numerical',
                    title: [
                      "Expected value: #{ number_with_precision(@expected_vals[x_val][y_val], precision: 3, significant: true) }",
                      "Percentage of row: #{ number_to_percentage(@delta_attrs[x_val][y_val][:percentage_of_row], precision: 3, significant: true) }",
                      "Percentage of col: #{ number_to_percentage(@delta_attrs[x_val][y_val][:percentage_of_col], precision: 3, significant: true) }",
                    ].join("\n"),
                    style: "color: #{ @delta_attrs[x_val][y_val][:color] };",
                  )
                } +
                [
                  Utils::RdeTableCell.new(
                    :th,
                    @observed_vals[:_sum][y_val],
                    title: "Percentage of col: #{ number_to_percentage(@delta_attrs[:_sum][y_val][:percentage_of_col], precision: 3, significant: true) }"
                  )
                ],
                css_class: 'rde-data_row'
              )
            } +
            # Footer row
            [
              Utils::RdeTableRow.new(
                :tr,
                [Utils::RdeTableCell.new(:th, 'Totals', css_class: 'rde-row_header')] +
                x_sorted_keys.map { |x_val|
                  Utils::RdeTableCell.new(
                    :th,
                    @observed_vals[x_val][:_sum],
                    title: "Percentage of row: #{ number_to_percentage(@delta_attrs[x_val][:_sum][:percentage_of_row], precision: 3, significant: true) }"
                  )
                } +
                [Utils::RdeTableCell.new(:th, @observed_vals[:_sum][:_sum])],
                css_class: 'rde-column_header'
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
        return ''  unless ca

        content_tag(:div, class: 'rde-chart rde-contingency-table', id: dom_id) do
          content_tag(:h3, "Contingency Table", class: 'rde-chart-title') +
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
        @observed_vals = { _sum: { _sum: 0 } }
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
        @delta_attrs = { _sum: {} }
        color_scale = RailsDataExplorer::Utils::ColorScale.new
        x_ds.uniq_vals.each { |x_val|
          @delta_attrs[x_val] = { _sum: {} }
          @delta_attrs[x_val][:_sum][:percentage_of_row] = (@observed_vals[x_val][:_sum] / @observed_vals[:_sum][:_sum].to_f) * 100
          y_ds.uniq_vals.each { |y_val|
            delta = @observed_vals[x_val][y_val] - @expected_vals[x_val][y_val]
            delta_factor = delta / @expected_vals[x_val][y_val].to_f
            @delta_attrs[x_val][y_val] = {
              expected: @expected_vals[x_val][y_val],
              color: color_scale.compute(delta_factor),
              delta: delta,
              delta_factor: delta_factor,
              percentage_of_row: (@observed_vals[x_val][y_val] / @observed_vals[:_sum][y_val].to_f) * 100,
              percentage_of_col: (@observed_vals[x_val][y_val] / @observed_vals[x_val][:_sum].to_f) * 100,
            }
            @delta_attrs[:_sum][y_val] ||= {
              percentage_of_col: (@observed_vals[:_sum][y_val] / @observed_vals[:_sum][:_sum].to_f) * 100
            }
          }
        }
        # Compute probability of observing a sample statistic as extreme as the
        # observed test statistic.
        @p_value = 1 - Distribution::ChiSquare.cdf(@chi_squared, @degrees_of_freedom)
        # Set significance_level
        @significance_level = 0.05
        # Compute conclusion
        all_observed_vals = []
        x_ds.uniq_vals.each { |x_val|
          y_ds.uniq_vals.each { |y_val|
            all_observed_vals << @observed_vals[x_val][y_val]
          }
        }
        observed_vals_less_than_five = all_observed_vals.find_all { |e| e < 5 }
        ratio_of_observed_vals_below_five = observed_vals_less_than_five.length / all_observed_vals.length.to_f

        if ratio_of_observed_vals_below_five > 0.2
          @conclusion = [
            "We did not run the ",
            %(<a href="http://en.wikipedia.org/wiki/Pearson%27s_chi-squared_test#Test_of_independence">Pearson chi squared test of independence</a> ),
            "since #{ number_to_percentage(ratio_of_observed_vals_below_five * 100, precision: 0) } ",
            "of observed values in the contingency table are below 5 (cutoff is 20%)."
          ].join
        elsif([x_ds, y_ds].any? { |e| e.uniq_vals.length < 2 })
          @conclusion = [
            "We did not run the ",
            %(<a href="http://en.wikipedia.org/wiki/Pearson%27s_chi-squared_test#Test_of_independence">Pearson chi squared test of independence</a> ),
            "since there are not enough observed values in the contingency table."
          ].join
        else
          @conclusion = %(<a href="http://en.wikipedia.org/wiki/Pearson%27s_chi-squared_test#Test_of_independence">Pearson chi squared test of independence</a> suggests that )
          @conclusion << if @p_value <= @significance_level
            %("#{ x_ds.name }" and "#{ y_ds.name }" are dependent variables (p_value of #{ number_with_precision(@p_value) } <= #{ number_with_precision(@significance_level )}))
          else
            %("#{ x_ds.name }" and "#{ y_ds.name }" are independent variables (p_value of #{ number_with_precision(@p_value) } > #{ number_with_precision(@significance_level )}))
          end
        end
        @conclusion = @conclusion.html_safe
      end
    end
  end
end
