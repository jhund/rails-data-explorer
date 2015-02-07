require_relative '../helper_no_rails'

class RailsDataExplorer
  describe DataSeries do

    describe "#initialize" do

      [
        [['a'], DataType::Categorical],
        [[nil, 'a'], DataType::Categorical],
        [[1.0], DataType::Quantitative::Decimal],
        [[1], DataType::Quantitative::Integer],
        [[Time.now], DataType::Quantitative::Temporal],
      ].each_with_index { |(values, xpect), idx|
        it "detects the datatype #{ idx } correctly" do
          DataSeries.new("name", values).data_type.must_be_instance_of xpect
        end
      }

    end

    describe "value accessors" do

      let(:ds) { DataSeries.new("name", ['b', 'a', 'a', 'c']) }

      it "computes uniq_vals" do
        ds.uniq_vals.must_equal ['b', 'a', 'c']
      end

      it "computes uniq_vals_count" do
        ds.uniq_vals_count.must_equal 3
      end

      it "computes min_val" do
        ds.min_val.must_equal 'a'
      end

      it "computes max_val" do
        ds.max_val.must_equal 'c'
      end

    end

  end
end
