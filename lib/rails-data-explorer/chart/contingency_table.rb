# See this project for code to compute chi_square and contingency_coefficient
# https://github.com/bioruby/bioruby/blob/master/lib/bio/util/contingency_table.rb
class RailsDataExplorer
  class Chart
    class ContingencyTable < Chart

      def initialize(_data_container, options = {})
        @data_container = _data_container
        @options = {}.merge(options)
      end

      def compute_chart_attrs
        x_candidates = @data_container.data_series.find_all { |ds|
          (ds.chart_roles[Chart::ContingencyTable] & [:x, :any]).any?
        }
        y_candidates = @data_container.data_series.find_all { |ds|
          (ds.chart_roles[Chart::ContingencyTable] & [:y, :any]).any?
        }

        x_ds = x_candidates.first
        y_ds = (y_candidates - [x_ds]).first

        # initialize data_matrix
        data_matrix = { :_sum => { :_sum => 0 } }
        x_ds.values.uniq.each { |x_val|
          data_matrix[x_val] = {}
          data_matrix[x_val][:_sum] = 0
          y_ds.values.uniq.each { |y_val|
            data_matrix[x_val][y_val] = 0
            data_matrix[:_sum][y_val] = 0
          }
        }
        # populate data_matrix
        x_ds.values.length.times { |idx|
          x_val = x_ds.values[idx]
          y_val = y_ds.values[idx]
          data_matrix[x_val][y_val] += 1
          data_matrix[:_sum][y_val] += 1
          data_matrix[x_val][:_sum] += 1
          data_matrix[:_sum][:_sum] += 1
        }

        x_sorted_keys = x_ds.values.uniq.sort { |a,b|
          data_matrix[b][:_sum] <=> data_matrix[a][:_sum]
        }
        y_sorted_keys = y_ds.values.uniq.sort { |a,b|
          data_matrix[:_sum][b] <=> data_matrix[:_sum][a]
        }

        cd = case @data_container.dimensions_count
        when 2
          {
            :table => [
              [{ :tag => :th, :content => '' }] + \
              x_sorted_keys.map { |x_val|
                { :tag => :th, :content => x_val }
              } + \
              [{ :tag => :th, :content => 'Totals' }]
            ] + \
            y_sorted_keys.map { |y_val|
              [{ :tag => :th, :content => y_val }] + \
              x_sorted_keys.map { |x_val|
                { :tag => :td, :content => data_matrix[x_val][y_val], :attrs => { :class => 'rde-numerical' } }
              } + [{ :tag => :th, :content => data_matrix[:_sum][y_val] }]
            } + \
            [
              [{ :tag => :th, :content => 'Totals' }] + \
              x_sorted_keys.map { |x_val|
                { :tag => :th, :content => data_matrix[x_val][:_sum] }
              } + \
              [{ :tag => :th, :content => data_matrix[:_sum][:_sum] }]
            ]
          }
        else
          raise(ArgumentError.new("Exactly two data series required for contingency table."))
        end
        cd
      end

      def render
        return ''  unless render?
        ca = compute_chart_attrs
        content_tag(:div, :class => 'rde-chart rde-contingency-table', :id => dom_id) do
          content_tag(:h3, "Contingency Table", :class => 'rde-chart-title') + \
          content_tag(:table) do
            ca[:table].map do |row|
              content_tag(:tr) do
                row.map do |cell|
                  content_tag(cell[:tag], cell[:content], cell[:attrs] || {})
                end.join.html_safe
              end
            end.join.html_safe
          end.html_safe
        end
      end

    end
  end
end
