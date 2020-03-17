module CoreExtensions
  module AfterInitialized
    class DateTest < ActiveSupport::TestCase
      test 'supports GlobalID' do
        assert_includes Date.included_modules, GlobalID::Identification
        assert_respond_to Date, :find
        assert_respond_to Date.new, :id
      end

      test '.find is an alias for .parse' do
        sample_date = Date.new

        assert_equal Date.parse(sample_date.to_s), Date.find(sample_date.to_s)
        assert_equal :parse, Date.method(:find).original_name
      end

      test '.today is an alias for .current' do
        assert_equal Date.current, Date.today
        assert_equal :current, Date.method(:today).original_name
      end

      test '#month_name gets the current month name from MONTHNAMES' do
        date = Date.new(2020,3,1)
        assert_equal "March", date.month_name
        date = Date.new(2020,6,1)
        assert_equal "June", date.month_name

        assert_equal Date::MONTHNAMES[Date.today.month], Date.today.month_name
      end
    end
  end
end
