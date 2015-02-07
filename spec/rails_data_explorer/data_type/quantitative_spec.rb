require_relative '../../helper_no_rails'

class RailsDataExplorer
  class DataType
    describe Quantitative do

      let(:dt) { Quantitative.new }
      let(:values) { (1..101).to_a }

      describe "#descriptive_statistics" do

        let(:desc_stats) {
          dt.descriptive_statistics(values)
        }

        it "computes 'Min'" do
          desc_stats.detect { |e| 'Min' == e[:label] }[:value].must_equal 1
        end

        it "computes '1%ile'" do
          desc_stats.detect { |e| '1%ile' == e[:label] }[:value].must_equal 3
        end

        it "computes '5%ile'" do
          desc_stats.detect { |e| '5%ile' == e[:label] }[:value].must_equal 7
        end

        it "computes '10%ile'" do
          desc_stats.detect { |e| '10%ile' == e[:label] }[:value].must_equal 12
        end

        it "computes '25%ile'" do
          desc_stats.detect { |e| '25%ile' == e[:label] }[:value].must_equal 27
        end

        it "computes 'Median'" do
          desc_stats.detect { |e| 'Median' == e[:label] }[:value].must_equal 51
        end

        it "computes '75%ile'" do
          desc_stats.detect { |e| '75%ile' == e[:label] }[:value].must_equal 77
        end

        it "computes '90%ile'" do
          desc_stats.detect { |e| '90%ile' == e[:label] }[:value].must_equal 92
        end

        it "computes '95%ile'" do
          desc_stats.detect { |e| '95%ile' == e[:label] }[:value].must_equal 97
        end

        it "computes '99%ile'" do
          desc_stats.detect { |e| '99%ile' == e[:label] }[:value].must_equal 101
        end

        it "computes 'Max'" do
          desc_stats.detect { |e| 'Max' == e[:label] }[:value].must_equal 101
        end

        it "computes 'Range'" do
          desc_stats.detect { |e| 'Range' == e[:label] }[:value].must_equal 100
        end

        it "computes 'Mean'" do
          desc_stats.detect { |e| 'Mean' == e[:label] }[:value].must_equal 51
        end

        it "computes 'Mode'" do
          desc_stats.detect { |e| 'Mode' == e[:label] }[:value].must_equal nil
        end

        it "computes 'Count'" do
          desc_stats.detect { |e| 'Count' == e[:label] }[:value].must_equal 101
        end

        it "computes 'Sum'" do
          desc_stats.detect { |e| 'Sum' == e[:label] }[:value].must_equal 5151
        end

        it "computes 'Variance'" do
          desc_stats.detect { |e| 'Variance' == e[:label] }[:value].must_equal 858.5
        end

        it "computes 'Std. dev.'" do
          desc_stats.detect { |e| 'Std. dev.' == e[:label] }[:value].must_equal 29.300170647967224
        end

        it "computes 'Rel. std. dev.'" do
          desc_stats.detect { |e| 'Rel. std. dev.' == e[:label] }[:value].must_equal 57.166195047502946
        end

        it "computes 'Skewness'" do
          desc_stats.detect { |e| 'Skewness' == e[:label] }[:value].must_equal 0.0
        end

        it "computes 'Kurtosis'" do
          desc_stats.detect { |e| 'Kurtosis' == e[:label] }[:value].must_equal 1.781945253348864
        end

      end

      describe '#axis_scale' do

        it 'determines linear' do
          ds = DataSeries.new('_', [1, 1_000])
          Quantitative.new.axis_scale(ds, {}, :vega).must_equal 'linear'
        end

        it 'determines log' do
          ds = DataSeries.new('_', [1, 1_000_000])
          Quantitative.new.axis_scale(ds, {}, :vega).must_equal 'log'
        end

      end

    end
  end
end
