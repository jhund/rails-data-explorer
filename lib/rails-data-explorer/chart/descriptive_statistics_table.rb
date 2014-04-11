class RailsDataExplorer
  class Chart
    class DescriptiveStatisticsTable < Chart

      def initialize(_data_container, options = {})
        @data_container = _data_container
        @options = {}.merge(options)
      end

      def render
        return ''  unless render?
        content_tag(:div, :id => dom_id, :class => 'rde-chart rde-descriptive-statistics-table') do
          @data_container.data_series.map { |data_series|
            content_tag(:h3, "Descriptive Statistics", :class => 'rde-chart-title') +
            content_tag(:table) do
              data_series.descriptive_statistics.map { |e|
                content_tag(:tr) do
                  content_tag(:th, e[:label]) +
                  content_tag(:td, instance_exec(e[:value], &e[:ruby_formatter]), :class => 'rde-numerical')
                end
              }.join.html_safe
            end
          }.join.html_safe
        end
      end

    end
  end
end
