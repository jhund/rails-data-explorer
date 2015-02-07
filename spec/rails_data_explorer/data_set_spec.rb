require_relative '../helper_no_rails'

class RailsDataExplorer
  describe DataSet do

    let(:data_set) {
      data_series_attrs = [
        { name: 'ds1', values: (1..6).to_a },
        { name: 'ds2', values: ('a'..'f').to_a },
      ]
      DataSet.new(data_series_attrs, 'the title')
    }

    it 'returns #data_series' do
      data_set.data_series.count.must_equal 2
    end

    it 'returns #number_of_values' do
      data_set.number_of_values.must_equal 6
    end

    it 'returns number of dimensions' do
      data_set.dimensions_count.must_equal 2
    end

    it 'returns data data_series_names' do
      data_set.data_series_names.must_equal ["ds1", "ds2"]
    end

  end
end
