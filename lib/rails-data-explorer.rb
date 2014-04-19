require 'action_view'
require 'active_support/all' # TODO: once the dust settles, only require the modules we need
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

require 'rails-data-explorer/chart/box_plot'
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

  def self.new_collection(data_collection, data_series_specs)
    explorations = []
    univariate = []
    bivariate = []
    multivariate = {}

    data_series_specs.each do |data_series_spec|
      data_series_spec = {
        :univariate => true,
        :bivariate => true,
      }.merge(data_series_spec)
      univariate << data_series_spec  if data_series_spec[:univariate]
      bivariate << data_series_spec  if data_series_spec[:bivariate]
      if data_series_spec[:multivariate]
        [*data_series_spec[:multivariate]].each { |multivariate_group_key|
          multivariate[multivariate_group_key] ||= []
          multivariate[multivariate_group_key] << data_series_spec
        }
      end
    end

    univariate.uniq.compact.each { |data_series_spec|
      explorations << new(
        data_series_spec[:name],
        data_collection.map(&data_series_spec[:data_method]),
      )
    }

    bivariate.uniq.compact.combination(2).each { |data_series_spec_pair|
      explorations << new(
        data_series_spec_pair.map { |e| e[:name] }.join(' vs. '),
        data_series_spec_pair.map { |data_series_spec|
          {
            :name => data_series_spec[:name],
            :values => data_collection.map(&data_series_spec[:data_method])
          }
        }
      )
    }

    multivariate.each { |mv_group_key, mv_data_series_specs|
      explorations << new(
        mv_group_key.to_s,
        mv_data_series_specs.uniq.compact.map { |data_series_spec|
          {
            :name => data_series_spec[:name],
            :values => data_collection.map(&data_series_spec[:data_method])
          }
        }
      )
    }

    explorations
  end

end
