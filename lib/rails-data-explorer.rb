require 'color'
require 'descriptive-statistics'
require 'distribution'
require 'interpolate'

require 'rails-data-explorer/engine'

require 'rails-data-explorer/chart'
require 'rails-data-explorer/data_series'
require 'rails-data-explorer/data_set'
require 'rails-data-explorer/data_type'
require 'rails-data-explorer/exploration'
require 'rails-data-explorer/statistics/rng_category'
require 'rails-data-explorer/statistics/rng_gaussian'
require 'rails-data-explorer/statistics/rng_power_law'
require 'rails-data-explorer/utils/color_scale'
require 'rails-data-explorer/utils/value_formatter'

require 'rails-data-explorer/chart/box_plot_group'
require 'rails-data-explorer/chart/contingency_table'
require 'rails-data-explorer/chart/descriptive_statistics_table'
require 'rails-data-explorer/chart/histogram_categorical'
require 'rails-data-explorer/chart/histogram_quantitative'
require 'rails-data-explorer/chart/histogram_temporal'
require 'rails-data-explorer/chart/parallel_coordinates'
require 'rails-data-explorer/chart/parallel_set'
require 'rails-data-explorer/chart/pie_chart'
require 'rails-data-explorer/chart/scatterplot'
require 'rails-data-explorer/chart/stacked_bar_chart_categorical_percent'
require 'rails-data-explorer/data_type/categorical'
require 'rails-data-explorer/data_type/quantitative'
require 'rails-data-explorer/data_type/quantitative/decimal'
require 'rails-data-explorer/data_type/quantitative/integer'
require 'rails-data-explorer/data_type/quantitative/temporal'

class RailsDataExplorer

  # Convenience method to instantiate new Exploration
  def self.new(*args)
    RailsDataExplorer::Exploration.new(*args)
  end

end
