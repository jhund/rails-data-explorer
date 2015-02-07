require_relative '../../../helper_no_rails'

class RailsDataExplorer
  class DataType
    class Quantitative
      describe Temporal do

        let(:dt) { Temporal.new }
        let(:values) { [DateTime.new(2015, 02, 06), DateTime.new(2015, 02, 07)] }

        describe "#descriptive_statistics" do

          let(:desc_stats) {
            dt.descriptive_statistics(values)
          }

          it "computes 'Min'" do
            desc_stats.detect { |e| 'Min' == e[:label] }[:value].must_equal DateTime.new(2015, 02, 06)
          end

          it "computes 'Max'" do
            desc_stats.detect { |e| 'Max' == e[:label] }[:value].must_equal DateTime.new(2015, 02, 07)
          end

          it "computes 'Count'" do
            desc_stats.detect { |e| 'Count' == e[:label] }[:value].must_equal 2
          end

        end

      end
    end
  end
end
