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

        cd = case @data_container.cardinality
        when 2
          {
            :table => [
              [{ :tag => :th, :content => '' }] + \
              x_ds.values.uniq.sort.map { |x_val|
                { :tag => :th, :content => x_val }
              } + \
              [{ :tag => :th, :content => 'Totals' }]
            ] + \
            y_ds.values.uniq.sort.map { |y_val|
              [{ :tag => :th, :content => y_val }] + \
              x_ds.values.uniq.sort.map { |x_val|
                { :tag => :td, :content => data_matrix[x_val][y_val] }
              } + [{ :tag => :th, :content => data_matrix[:_sum][y_val] }]
            } + \
            [
              [{ :tag => :th, :content => 'Totals' }] + \
              x_ds.values.uniq.sort.map { |x_val|
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
        ca = compute_chart_attrs
        "<h3>Contingency Table</h3>" + \
        content_tag(:table) do
          ca[:table].map do |row|
            content_tag(:tr) do
              row.map do |cell|
                content_tag(cell[:tag], cell[:content])
              end.join.html_safe
            end
          end.join.html_safe
        end.html_safe
      end

    end
  end
end
