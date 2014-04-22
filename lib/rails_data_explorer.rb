class RailsDataExplorer

  attr_accessor :output_buffer # required for content_tag
  include ActionView::Helpers::TagHelper

  attr_reader :explorations

  def initialize(data_collection, data_series_specs)
    @explorations = []
    univariate = []
    bivariate = {}
    multivariate = {}

    data_series_specs.each do |data_series_spec|
      ds_spec = {
        :univariate => true,
        :bivariate => true,
      }.merge(data_series_spec)
      univariate << ds_spec.dup  if ds_spec[:univariate]

      if ds_spec[:bivariate]
        [*ds_spec[:bivariate]].each { |group_key|
          group_key = group_key.to_s
          bivariate[group_key] ||= []
          bivariate[group_key] << ds_spec.dup
        }
      end

      if ds_spec[:multivariate]
        [*ds_spec[:multivariate]].each { |group_key|
          group_key = group_key.to_s
          multivariate[group_key] ||= []
          multivariate[group_key] << ds_spec.dup
        }
      end
    end

    univariate.uniq.compact.each { |data_series_spec|
      @explorations << Exploration.new(
        data_series_spec[:name],
        data_collection.map(&data_series_spec[:data_method]),
      )
    }

    bivariate.each { |group_key, bv_data_series_specs|
      next  unless group_key # skip if key is falsey
      bv_data_series_specs.uniq.compact.combination(2) { |ds_specs_pair|
        @explorations << build_exploration_from_data_series_specs(
          data_collection,
          ds_specs_pair
        )
      }
    }

    multivariate.each { |group_key, mv_data_series_specs|
      next  unless group_key # skip key `false` or `nil`
      ds_specs = mv_data_series_specs.uniq.compact
      @explorations << build_exploration_from_data_series_specs(
        data_collection,
        ds_specs
      )
    }
  end

  def render
    expls = separate_explorations_with_and_without_charts
    r = render_toc(expls[:with])
    r << render_charts(expls[:with])
    r << render_explorations_without_charts(expls[:without])
    r
  end

private

  def build_exploration_from_data_series_specs(data_collection, ds_specs)
    Exploration.new(
      ds_specs.map { |e| e[:name] }.sort.join(' vs. '),
      ds_specs.map { |ds_spec|
        {
          :name => ds_spec[:name],
          :values => data_collection.map(&ds_spec[:data_method])
        }
      }
    )
  end

  def render_toc(expls)
    content_tag(:div, :class => 'rde panel panel-primary') do
      content_tag(:div, :class => 'panel-heading') do
        content_tag(:h2, "Table of contents", :class => 'rde-exploration-title panel-title')
      end +
      content_tag(:div, :class => 'panel-body') do
        content_tag(:ol, :class => 'rde-table_of_contents') do
          expls.map { |expl|
            content_tag(
              :li,
              %(<a href="##{ expl.dom_id }">#{ expl.title }</a>).html_safe
            )
          }.join.html_safe
        end
      end
    end
  end

  def render_charts(expls)
    expls.map { |e| e.render }.join.html_safe
  end

  def render_explorations_without_charts(expls)
    return ''  if expls.empty?
    content_tag(:div, :class => 'rde panel panel-default') do
      content_tag(:div, :class => 'panel-heading') do
        content_tag(:h2, "Explorations without charts", :class => 'rde-exploration-title panel-title')
      end +
      content_tag(:div, :class => 'panel-body') do
        content_tag(:p, "There are no charts available for the following explorations:") +
        content_tag(:ul) do
          expls.map { |expl|
            content_tag(:li, expl.title).html_safe
          }.join.html_safe
        end
      end
    end
  end

  def separate_explorations_with_and_without_charts
    explorations.inject({ :with => [], :without => [] }) { |m, e|
      m[e.charts.any? ? :with : :without] << e
      m
    }
  end

end
