require_relative '../../helper_no_rails'

class RailsDataExplorer
  module Utils
    describe DataQuantizer do

      describe '#quantize' do

        [
          [
            '4 values, 1-3.1',
            [1,2,3,3.1],
            {},
            {
              values: [1.0, 1.99, 3.01, 3.1],
              delta: 0.03
            }
          ],
          [
            '4 values, 0.001-0.03',
            [0.001,0.002,0.01,0.03],
            {},
            {
              values: [0.0009, 0.0021, 0.009899999999999999, 0.03],
              delta: 0.0003
            }
          ],
          [
            '10 values between 1.0 and 2.0',
            [1.000001, 1.1, 1.10001, 1.11, 1.15, 1.201, 1.205, 1.211, 1.999999],
            {},
            {
              values: [1.0, 1.1, 1.1, 1.11, 1.15, 1.2, 1.21, 1.21, 2.0],
              delta: 0.01
            }
          ],
          [
            '9 values around 10, one outlier at 100',
            9.times.map { rand + 9.5 } + [100],
            {},
            {
              values: [10.0, 10.0, 10.0, 10.0, 10.0, 10.0, 10.0, 10.0, 10.0, 100.0],
              delta: 1.0
            }
          ],
          [
            '2 clusters of 5 values each at 1.0 and 2.0',
            5.times.map { 1 + (rand/100.0) } + 5.times.map { 2 + (rand/100.0) },
            {},
            {
              values: [1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 2.0, 2.0, 2.0, 2.0],
              delta: 0.02
            }
          ],
        ].each do |(name, vals, options, xpect)|

          it "quantizes #{ name }" do
            ds = DataSeries.new('_', vals)
            dq = DataQuantizer.new(ds, options)
            dq.values.must_equal xpect[:values]  if xpect[:values]
            dq.number_of_bins.must_equal xpect[:number_of_bins]  if xpect[:number_of_bins]
            dq.delta.must_equal xpect[:delta]  if xpect[:delta]
          end

        end

      end

    end
  end
end
