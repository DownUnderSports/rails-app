module CoreExtensions
  module AfterInitialized
    class IntegerTest < ActiveSupport::TestCase
      test  '#cents returns a StoreAsInt::Money' \
            ' as the number of pennies (2 digit decimal accuracy)' do
        assert_instance_of StoreAsInt::Money, 1.cents
        assert_equal (1/(100.to_d)).to_i, 1.cents.to_d.to_i
      end

      test  '#percent returns a StoreAsInt::ExchangeRate' \
            ' with a 10 digit decimal accuracy' do
        assert_instance_of StoreAsInt::ExchangeRate, 1.percent
        assert_equal (1/(1_0000000000.to_d)).to_i, 1.percent.to_d.to_i
      end
    end
  end
end
