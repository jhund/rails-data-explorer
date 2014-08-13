class RailsDataExplorer
  class DataType
    class Categorical < DataType

      def all_available_chart_types
        [
          {
            :chart_class => Chart::HistogramCategorical,
            :chart_roles => [:x],
            :dimensions_count_min => 1,
            :dimensions_count_max => 1,
          },
          # {
          #   :chart_class => Chart::PieChart,
          #   :chart_roles => [:any],
          #   :dimensions_count_min => 1,
          #   :dimensions_count_max => 1,
          # },
          {
            chart_class: Chart::BoxPlotGroup,
            chart_roles: [:y],
            dimensions_count_min: 2,
            dimensions_count_max: 2,
          },
          {
            chart_class: Chart::Scatterplot,
            chart_roles: [:color],
            dimensions_count_min: 3,
          },
          {
            chart_class: Chart::ParallelCoordinates,
            chart_roles: [:dimension],
            dimensions_count_min: 3,
          },
          {
            chart_class: Chart::StackedBarChartCategoricalPercent,
            chart_roles: [:x, :y],
            dimensions_count_min: 2,
            dimensions_count_max: 2,
          },
          {
            chart_class: Chart::ContingencyTable,
            chart_roles: [:any],
            dimensions_count_min: 2,
            dimensions_count_max: 2,
          },
          {
            chart_class: Chart::DescriptiveStatisticsTable,
            chart_roles: [:any],
            dimensions_count_min: 1,
            dimensions_count_max: 1,
          },
          {
            chart_class: Chart::ParallelSet,
            chart_roles: [:dimension],
            dimensions_count_min: 3,
          },
        ].freeze
      end

      def descriptive_statistics(values)
        frequencies = values.inject(Hash.new(0)) { |m,e| m[e] += 1; m }
        labels_ds = DataSeries.new('_', values.uniq)
        total_count = values.length
        ruby_formatters = {
          :integer => Proc.new { |v| number_with_delimiter(v.round) },
          :percent => Proc.new { |v| number_to_percentage(v, :precision => 3, :significant => true, :strip_insignificant_zeros => true, :delimiter => ',') },
        }
        r = frequencies.inject([]) { |m, (k,v)|
          m << { :label => "#{ k.to_s }_count", :value => v, :ruby_formatter => ruby_formatters[:integer] }
          m << { :label => "#{ k.to_s }_percent", :value => (v / total_count.to_f) * 100, :ruby_formatter => ruby_formatters[:percent] }
          m
        }.sort(
          &labels_ds.label_sorter(
            :label,
            lambda { |a,b| b[:value] <=> a[:value] }
          )
        )
        r.insert(0, { :label => '[Total]_count', :value => total_count, :ruby_formatter => ruby_formatters[:integer] })
        r.insert(0, { :label => '[Total]_percent', :value => 100, :ruby_formatter => ruby_formatters[:percent] })
        r
      end

      # Returns an OpenStruct that describes a statistics table.
      def descriptive_statistics_table(values)
        desc_stats = descriptive_statistics(values)
        if desc_stats.length < DataSeries.many_uniq_vals_threshold
          descriptive_statistics_table_horizontal(desc_stats)
        else
          descriptive_statistics_table_vertical(desc_stats)
        end
      end

      def descriptive_statistics_table_horizontal(desc_stats)
        labels = desc_stats.map { |e| e[:label].gsub(/_count|_percent/, '') }.uniq
        table = OpenStruct.new(
          :rows => []
        )
        table.rows << OpenStruct.new(
          :css_class => 'rde-column_header',
          :tag => :tr,
          :cells => labels.map { |label|
            OpenStruct.new(:value => label, :ruby_formatter => Proc.new { |e| e }, :tag => :th, :css_class => 'rde-cell-label')
          }
        )
        table.rows << OpenStruct.new(
          :css_class => 'rde-data_row',
          :tag => :tr,
          :cells => labels.map { |label|
            stat = desc_stats.detect { |e| "#{ label }_count" == e[:label] }
            OpenStruct.new(:value => stat[:value], :ruby_formatter => stat[:ruby_formatter], :tag => :td, :css_class => 'rde-cell-value')
          }
        )
        table.rows << OpenStruct.new(
          :css_class => 'rde-data_row',
          :tag => :tr,
          :cells => labels.map { |label|
            stat = desc_stats.detect { |e| "#{ label }_percent" == e[:label] }
            OpenStruct.new(:value => stat[:value], :ruby_formatter => stat[:ruby_formatter], :tag => :td, :css_class => 'rde-cell-value')
          }
        )
        table
      end

      def descriptive_statistics_table_vertical(desc_stats)
        labels = desc_stats.map { |e| e[:label].gsub(/_count|_percent/, '') }.uniq
        table = OpenStruct.new(
          :rows => []
        )
        table.rows << OpenStruct.new(
          :css_class => 'rde-column_header',
          :tag => :tr,
          :cells => %w[Value Count Percent].map { |label|
            OpenStruct.new(:value => label, :tag => :th, :css_class => 'rde-cell-label')
          }
        )
        labels.each { |label|
          count_stat = desc_stats.detect { |e| "#{ label }_count" == e[:label] }
          percent_stat = desc_stats.detect { |e| "#{ label }_percent" == e[:label] }
          table.rows << OpenStruct.new(
            :css_class => 'rde-data_row',
            :tag => :tr,
            :cells => [
              OpenStruct.new(:value => label, :tag => :td, :css_class => 'rde-cell-value'),
              OpenStruct.new(
                :value => count_stat[:value],
                :ruby_formatter => count_stat[:ruby_formatter],
                :tag => :td,
                :css_class => 'rde-cell-value'
              ),
              OpenStruct.new(
                :value => percent_stat[:value],
                :ruby_formatter => percent_stat[:ruby_formatter],
                :tag => :td,
                :css_class => 'rde-cell-value'
              ),
            ]
          )
        }
        table
      end

      def axis_tick_format(values)
        %(function(d) { return d })
      end

      # @param[Symbol, nil] label_val_key the hash key to use to get the label value during sort (sent to a,b)
      # @param[DataSeries] data_series the ds that contains the uniq vals
      # @param[Proc] value_sorter the sorting proc to use if not sorted numerically
      # @return[Proc] a Proc that will be used by #sort
      def label_sorter(label_val_key, data_series, value_sorter)
        if data_series.uniq_vals.any? { |e| e.to_s =~ /^[\+\-]?\d+/ }
          # Sort numerical categories by key ASC
          lambda { |a,b|
            number_and_full_string_extractor = lambda { |val|
              str = label_val_key ? val[label_val_key] : val
              number = str.gsub(/^[^\d\+\-]*/, '') # remove non-digit leading chars
                          .gsub(',', '') # remove delimiter commas, they throw off to_f parsing
                          .to_f
              number += 1  if str =~ /^>/ # increase highest threshold by one for proper sorting
              [number, str]
            }
            a_number_and_full_string = number_and_full_string_extractor.call(a)
            b_number_and_full_string = number_and_full_string_extractor.call(b)
            a_number_and_full_string <=> b_number_and_full_string
          }
        else
          # Use provided value sorter
          value_sorter
        end
      end

    end
  end
end
