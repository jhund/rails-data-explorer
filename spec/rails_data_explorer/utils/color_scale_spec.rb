require_relative '../../helper_no_rails'

class RailsDataExplorer
  module Utils
    describe ColorScale do

      it 'computes a color from an input value' do
        ColorScale.new.compute(0).must_equal '#000000'
      end

    end
  end
end
