require_relative '../helper_no_rails'

class RailsDataExplorer
  describe Exploration do

    describe "integration test" do

      def check_render_expectations(rendered_string, options)
        r = true

        if options[:has_charts]
          options[:has_charts].each { |chart_name|
            # TODO: use Nokogiri to test that it is a div class
            rendered_string.must_match(
              Regexp.new(Regexp.escape("rde-#{ chart_name }"))
            )
          }
        end

        r
      end

      [
        [
          ['Univariate Integer data', [1, 2, 3]],
          { has_charts: ['histogram-quantitative', 'descriptive-statistics-table'] }
        ],
        [
          ['Univariate Decimal data', [1.0, 2.0, 3.0]],
          { has_charts: ['histogram-quantitative', 'descriptive-statistics-table'] }
        ],
        [
          ['Univariate Temporal data', [DateTime.new(2015,2,7)]],
          { has_charts: ['histogram-temporal', 'descriptive-statistics-table'] }
        ],
        [
          ['Univariate Categorical data', ['a', 'b', 'c']],
          { has_charts: ['histogram-categorical', 'pie-chart', 'descriptive-statistics-table'] }
        ],
      ].each { |(args, xpect_options)|
        title, data_set_or_array, chart_specs = args

        it "renders #{ title } correctly" do
          check_render_expectations(
            Exploration.new(*args, true).render,
            xpect_options
          )
        end

      }

    end

  end
end
