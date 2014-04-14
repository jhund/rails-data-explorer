class RailsDataExplorer
  class Chart
    class DescriptiveStatisticsTable < Chart

      def initialize(_data_set, options = {})
        @data_set = _data_set
        @options = {}.merge(options)
      end

      def render
        return ''  unless render?
        content_tag(:div, :id => dom_id, :class => 'rde-chart rde-descriptive-statistics-table') do
          @data_set.data_series.map { |data_series|
            content_tag(:h3, "Descriptive Statistics", :class => 'rde-chart-title') +
            render_html_table(data_series.descriptive_statistics_table)
          }.join.html_safe
        end
      end

    end
  end
end
