require 'descriptive-statistics'

require 'rails-data-explorer/engine'

require 'rails-data-explorer/chart'
require 'rails-data-explorer/data_container'
require 'rails-data-explorer/data_series'
require 'rails-data-explorer/data_type'
require 'rails-data-explorer/exploration'

require 'rails-data-explorer/chart/contingency_table'
require 'rails-data-explorer/chart/descriptive_statistics_table'
require 'rails-data-explorer/chart/histogram_categorical'
require 'rails-data-explorer/chart/histogram_quantitative'
require 'rails-data-explorer/chart/histogram_temporal'
require 'rails-data-explorer/chart/scatterplot'
require 'rails-data-explorer/data_type/categorical'
require 'rails-data-explorer/data_type/quantitative'
require 'rails-data-explorer/data_type/temporal'

class RailsDataExplorer

  # Convenience method to instantiate new Exploration
  def self.new(*args)
    RailsDataExplorer::Exploration.new(*args)
  end

end
