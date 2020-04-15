module CoreExtensions
  module AfterInitialized
    class IntegerTest < ActiveSupport::TestCase
      test '#cents returns a StoreAsInt::Money' \
            ' as the number of pennies (2 digit decimal accuracy)' do
        assert_instance_of StoreAsInt::Money, 1.cents
        assert_equal (1/(100.to_d)).to_i, 1.cents.to_d.to_i
      end

      test '#percent returns a StoreAsInt::ExchangeRate' \
            ' with a 10 digit decimal accuracy' do
        assert_instance_of StoreAsInt::ExchangeRate, 1.percent
        assert_equal (1/(1_0000000000.to_d)).to_i, 1.percent.to_d.to_i
      end

      test '#min_max returns a number between two inclusive numbers' do
        assert_equal 0, -1.min_max(0, 10)
        assert_equal 0, 0.min_max(0, 10)
        assert_equal 5, 5.min_max(0, 10)
        assert_equal 10, 100.min_max(0, 10)
        assert_equal -1, -1.min_max(-10, 10)
        assert_equal 10, 100.min_max(-10, 10)
        assert_equal 10, 10.min_max(-10, 10)
      end
    end
  end
end
