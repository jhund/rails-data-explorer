require_relative '../helper_no_rails'

class RailsDataExplorer
  describe Chart do

    it 'computes a dom id' do
      Chart.new.dom_id.must_match /rde-chart-\d/
    end

  end
end
