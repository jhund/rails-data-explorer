

require 'action_view'
require 'active_support/all' # TODO: once the dust settles, only require the modules we need
require 'color'
require 'descriptive-statistics'
require 'distribution'
require 'interpolate'

require 'rails_data_explorer/action_view_extension.rb'

require 'rails_data_explorer/engine.rb'
# dependency boundary

require 'rails_data_explorer.rb'
require 'rails_data_explorer/chart.rb'
require 'rails_data_explorer/data_series.rb'
require 'rails_data_explorer/data_set.rb'
require 'rails_data_explorer/data_type.rb'
require 'rails_data_explorer/exploration.rb'
require 'rails_data_explorer/statistics/rng_category.rb'
require 'rails_data_explorer/statistics/rng_gaussian.rb'
require 'rails_data_explorer/statistics/rng_power_law.rb'
require 'rails_data_explorer/utils/color_scale.rb'
require 'rails_data_explorer/utils/data_binner.rb'
require 'rails_data_explorer/utils/data_quantizer.rb'
require 'rails_data_explorer/utils/rde_table.rb'
require 'rails_data_explorer/utils/value_formatter.rb'

# dependency boundary

require 'rails_data_explorer/chart/box_plot.rb'
require 'rails_data_explorer/chart/box_plot_group.rb'
require 'rails_data_explorer/chart/contingency_table.rb'
require 'rails_data_explorer/chart/descriptive_statistics_table.rb'
require 'rails_data_explorer/chart/histogram_categorical.rb'
require 'rails_data_explorer/chart/histogram_quantitative.rb'
require 'rails_data_explorer/chart/histogram_temporal.rb'
require 'rails_data_explorer/chart/parallel_coordinates.rb'
require 'rails_data_explorer/chart/parallel_set.rb'
require 'rails_data_explorer/chart/pie_chart.rb'
require 'rails_data_explorer/chart/scatterplot.rb'
require 'rails_data_explorer/chart/stacked_bar_chart_categorical.rb'
# require 'rails_data_explorer/chart/stacked_histogram_temporal.rb'
require 'rails_data_explorer/data_type/categorical.rb'
require 'rails_data_explorer/data_type/quantitative.rb'
require 'rails_data_explorer/data_type/quantitative/decimal.rb'
require 'rails_data_explorer/data_type/quantitative/integer.rb'
require 'rails_data_explorer/data_type/quantitative/temporal.rb'

# dependency boundary

require 'rails_data_explorer/chart/stacked_bar_chart_categorical_percent.rb'
