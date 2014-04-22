require_relative '../../helper_no_rails'

class RailsDataExplorer
  module Utils
    describe DataBinner do

      describe '#bin' do

        [
          [
            '1',
            { '1 or less' => 1, '2' => 2, '3' => 3 },
            [0,1,2,3,4],
            ['1 or less', '1 or less', '2', '3', '> 3']
          ],
        ].each do |(name, bin_specs, vals, xpect)|

          it "bins #{ name }" do
            db = DataBinner.new(bin_specs)
            vals.map{ |e| db.bin(e) }.must_equal xpect
          end

        end

      end

    end
  end
end
