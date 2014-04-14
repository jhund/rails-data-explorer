# http://www.jasondavies.com/parallel-sets/
# Suitable when all data series are categorical
class RailsDataExplorer
  class Chart
    class ParallelSet < Chart

      def initialize(_data_set, options = {})
        @data_set = _data_set
        @options = {}.merge(options)
      end

      def compute_chart_attrs
        dimension_data_series = @data_set.data_series.find_all { |ds|
          (ds.chart_roles[Chart::ParallelCoordinates] & [:dimension, :any]).any?
        }
        number_of_values = dimension_data_series.first.values.length
        dimension_names = dimension_data_series.map(&:name)
        dimension_values = number_of_values.times.map do |idx|
          dimension_data_series.inject({}) { |m,ds|
            m[ds.name] = if ds.data_type.is_a?(RailsDataExplorer::DataType::Quantitative::Temporal)
              ds.values[idx].to_i * 1000
            else
              ds.values[idx]
            end
            m
          }
        end
        {
          :dimensions => dimension_names,
          :values => dimension_values
        }
      end

      def render
        return ''  unless render?
        ca = compute_chart_attrs
        %(
          <div class="rde-chart rde-parallel-set">
            <h3 class="rde-chart-title">Parallel Set</h3>
            <div id="#{ dom_id }" class="rde-chart-parallel-set" style="height: 600px; width: 100%"></div>
            <script type="text/javascript">
              (function() {
                var parset = d3.parsets()
                               .dimensions(#{ ca[:dimensions ].to_json })
                               ;

                var vis = d3.select("##{ dom_id }")
                            .append("svg")
                            .attr("width", parset.width())
                            .attr("height", parset.height())
                            ;

                vis.datum(#{ ca[:values].to_json })
                   .call(parset)
                   ;

              })();
            </script>
          </div>
        )
      end

    end
  end
end
