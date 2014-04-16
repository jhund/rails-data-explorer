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
          desc_stats.detect{ |e| 'Total_count' == e[:label] }[:value].must_equal 4
        end
      end

      describe "#available_chart_types" do
      end

    end
  end
end
