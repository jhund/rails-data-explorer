# -*- coding: utf-8 -*-

class RailsDataExplorer

  # Responsibilities:
  #  * Add rails-data-explorer view helpers to ActionView
  #  * Render rails-data-explorer generated content
  #
  # Collaborators:
  #  * RailsDataExplorer
  #  * Exploration
  #
  module ActionViewExtension

    # Renders the entire RailsDataExplorer view
    # @param rde [RailsDataExplorer]
    def rails_data_explorer(rde)
      content_tag(:div, class: 'rails-data-explorer') do
        [
          rde_toc(rde.data_series_names, rde.explorations_with_charts_available),
          rde_explorations_with_charts(rde.explorations_with_charts_to_render),
        ].join.html_safe
      end
    end

    # Returns a url that can be used to reset the Filterrific params
    def reset_filterrific_url(opts = {})
      url_for(
        { filterrific: { reset_filterrific: true } }.merge(opts)
      )
    end

  protected

    # @param ds_names [Array<String>] the names of the data_series
    # @param explorations [Array<Exploration>]
    def rde_toc(ds_names, explorations)
      reversed_ds_names = ds_names.reverse
      num_cols = 2 + ds_names.length
      content_tag(:div, class: 'rde panel panel-primary') do
        content_tag(:div, class: 'panel-heading') do
          %(<a name="rails_data_explorer-toc"></a>).html_safe +
          content_tag(:h2, "List of data explorations", class: 'rde-exploration-title panel-title')
        end +
        content_tag(:div, class: 'panel-body') do
          content_tag(:table, class: 'table rde_toc-matrix') do
            # render uni-/bi-variate analysis column headers (with reversed data_series names)
            content_tag(:tr) do
              content_tag(
                :td,
                link_to(
                  'All Univariates ⬇',
                  url_for(
                    rde: {
                      univariate: ds_names.each_with_index.inject({}) { |m, (e, idx)|
                        m[idx] = [e]
                        m
                      }
                    },
                    anchor: 'rails_data_explorer-toc',
                  ),
                  class: 'btn btn-default btn-xs',
                  title: 'Load univariate explorations for all data series.'
                ),
                colspan: 2
              ) +
              reversed_ds_names.map { |ds_name|
                content_tag(:th, ds_name, class: 'rde_toc-col_header')
              }.join.html_safe
            end +
            # iterate over data_series
            ds_names.map { |ds_name|
              content_tag(:tr) do
                uv_expl = explorations.detect { |e|
                  e.dom_id == RailsDataExplorer::Exploration.compute_dom_id(
                    [ds_name]
                  )
                }
                encountered_bv_with_self = false
                # row header with data_series name
                content_tag(
                  :th,
                  ds_name.truncate(12),
                  class: 'rde_toc-row_header',
                  title: ds_name
                ) +
                # cell with link to univariate analysis
                if uv_expl
                  tooltip_suffix = "univariate exploration for #{ ds_name.inspect }."
                  if uv_expl.render_charts?
                    # Link to anchor on current page (chart is currently rendered)
                    content_tag(
                      :td,
                      link_to(
                        '⬅',
                        "##{ uv_expl.dom_id }",
                        class: 'btn btn-default btn-xs'
                      ),
                      class: 'rde_toc-currently_rendered',
                      title: 'Jump to ' + tooltip_suffix,
                    )
                  else
                    # Load new page
                    content_tag(
                      :td,
                      link_to(
                        '⬅',
                        url_for(
                          rde: { univariate: { '1' => uv_expl.data_series_names }},
                          anchor: uv_expl.dom_id
                        ),
                        class: 'btn btn-default btn-xs'
                      ),
                      class: 'rde_toc-available_not_rendered',
                      title: 'Load ' + tooltip_suffix,
                    )
                  end
                else
                  # show that no exploration exists
                  content_tag(
                    :td,
                    'N/A',
                    class: 'rde_toc-not_available',
                    title: 'There is no ' + tooltip_suffix,
                  )
                end +
                # iterate over reversed data_series names
                reversed_ds_names.map { |r_ds_name|
                  bv_expl = explorations.detect { |e|
                    e.dom_id == RailsDataExplorer::Exploration.compute_dom_id(
                      [ds_name, r_ds_name]
                    )
                  }
                  bv_ds_names = [ds_name.inspect, r_ds_name.inspect].sort.join(' vs. ')
                  tooltip_suffix = "bivariate exploration for #{ bv_ds_names }."
                  if encountered_bv_with_self
                    # blank cell
                    '<td class="rde_toc-oso_diagonal"></td>'.html_safe
                  elsif ds_name == r_ds_name
                    # intersection with self
                    encountered_bv_with_self = true
                    params_counter = '0'
                    # Link to anchor on new page (chart is currently not rendered)
                    content_tag(
                      :td,
                      link_to(
                        image_tag('rails-data-explorer/multiple_bivariate_small.png'),
                        url_for(
                          rde: {
                            univariate: { '1' => [r_ds_name] },
                            bivariate: ds_names.each_with_object({}) { |e,m|
                              next  if r_ds_name == e # skip bivariate with self
                              m[params_counter.succ!] = [r_ds_name, e]
                            }
                          },
                          anchor: 'rails_data_explorer-toc',
                        ),
                        class: 'btn btn-default btn-xs'
                      ),
                      class: 'rde_toc-available_not_rendered',
                      title: "Load all bivariate explorations for #{ ds_name.inspect }.",
                    )
                  elsif bv_expl
                    # bivariate analysis exists
                    if bv_expl.render_charts?
                      # Link to anchor on current page (chart is currently rendered)
                      content_tag(
                        :td,
                        link_to(
                          'X',
                          "##{ bv_expl.dom_id }",
                          class: 'btn btn-default btn-xs'
                        ),
                        class: 'rde_toc-currently_rendered',
                        title: 'Jump to ' + tooltip_suffix,
                      )
                    else
                      # Link to anchor on new page (chart is currently not rendered)
                      content_tag(
                        :td,
                        link_to(
                          'X',
                          url_for(
                            rde: { bivariate: { '1' => bv_expl.data_series_names }},
                            anchor: bv_expl.dom_id
                          ),
                          class: 'btn btn-default btn-xs'
                        ),
                        class: 'rde_toc-available_not_rendered',
                        title: 'Load ' + tooltip_suffix,
                      )
                    end
                  else
                    # show that no exploration exists
                    content_tag(
                      :td,
                      'N/A',
                      class: 'rde_toc-not_available',
                      title: 'There is no ' + tooltip_suffix,
                    )
                  end
                }.join.html_safe
              end
            }.join.html_safe
          end
        end
      end
    end

    def rde_explorations_with_charts(explorations)
      explorations.map { |e| e.render }.join.html_safe
    end

  end
end
