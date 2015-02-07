require_relative '../../helper_no_rails'

class RailsDataExplorer
  module Utils
    describe ValueFormatter do

      describe 'initialize from options' do

        let(:value_formatter) {
          ValueFormatter.new(
            d3_format: 'd3f',
            ruby_formatter: 'rf',
            significant_figures: 2
          )
        }

        it 'has d3_format' do
          value_formatter.d3_format.must_equal 'd3f'
        end

        it 'has ruby_formatter' do
          value_formatter.ruby_formatter.must_equal 'rf'
        end

        it 'has significant_figures' do
          value_formatter.significant_figures.must_equal 2
        end

      end

    end
  end
end
