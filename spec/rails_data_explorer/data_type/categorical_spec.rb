require_relative '../../helper_no_rails'

class RailsDataExplorer
  class DataType
    describe Categorical do

      let(:dt) { Categorical.new }
      let(:values) { ['a', 'a', 'b', 'c'] }

      describe "#descriptive_statistics" do

        let(:desc_stats) {
          dt.descriptive_statistics(values)
        }

        it "computes count for each uniq val" do
          desc_stats.detect{ |e| 'a_count' == e[:label] }[:value].must_equal 2
        end

        it "computes percent for each uniq val" do
          desc_stats.detect{ |e| 'a_percent' == e[:label] }[:value].must_equal 50.0
        end

        it "computes total count" do
          desc_stats.detect{ |e| '[Total]_count' == e[:label] }[:value].must_equal 4
        end
      end

      describe "#available_chart_types" do
      end

      describe '#label_sorter' do

        it 'sorts numerical labels with greater and less than signs' do
          labels = ['3', '< -1', '2', '1', '0', '> 3', '-1']
          ds = DataSeries.new('_', labels)
          labels.sort(
            &Categorical.new.label_sorter(nil, ds, '_')
          ).must_equal(['< -1', '-1', '0', '1', '2', '3', '> 3'])
        end

        it 'sorts mixed numerical and non-numerical labels with non-num at the end' do
          labels = ['3', '2', '[Other]', '1']
          ds = DataSeries.new('_', labels)
          labels.sort(
            &Categorical.new.label_sorter(nil, ds, '_')
          ).must_equal(['1', '2', '3', '[Other]'])
        end

        it 'accesses label_val_key if given' do
          labels = ['2', '1']
          ds = DataSeries.new('_', labels)
          labels.map { |e| { x: e } }.sort(
            &Categorical.new.label_sorter(:x, ds, '_')
          ).must_equal([{ x: '1' }, { x: '2' }])
        end

      end

      describe '#limit_distinct_values' do

        let(:vals) {
          %w[
            a a a a a a a a a a a a a
            b b b b
            c
            d
            e e e e e
            f f f f f f f
            g
            h h h h
          ]
        }

        it 'reduces large number of observations to smaller number' do
          Categorical.new.limit_distinct_values(vals, 4).must_equal(
            %w[
              a a a a a a a a a a a a a
              [Other] [Other] [Other] [Other]
              [Other]
              [Other]
              e e e e e
              f f f f f f f
              [Other]
              [Other] [Other] [Other] [Other]
            ]
          )
        end

        it 'allows override for val_for_others' do
          Categorical.new.limit_distinct_values(
            vals, 4, 'override'
          ).must_equal(
            %w[
              a a a a a a a a a a a a a
              override override override override
              override
              override
              e e e e e
              f f f f f f f
              override
              override override override override
            ]
          )
        end

        it 'uses label value as tie breaker on equal frequencies' do
          Categorical.new.limit_distinct_values(vals, 5).must_equal(
            %w[
              a a a a a a a a a a a a a
              b b b b
              [Other]
              [Other]
              e e e e e
              f f f f f f f
              [Other]
              [Other] [Other] [Other] [Other]
            ]
          )
        end

      end

    end
  end
end
