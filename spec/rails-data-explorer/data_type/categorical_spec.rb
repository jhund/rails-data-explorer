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

      describe '#reduce_distinct_values' do

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
          Categorical.new.reduce_distinct_values(vals, 4).must_equal(
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
          Categorical.new.reduce_distinct_values(
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
          Categorical.new.reduce_distinct_values(vals, 5).must_equal(
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
