module CoreExtensions
  module AfterInitialized
    class IntegerTest < ActiveSupport::TestCase
      test '#cents returns a StoreAsInt::Money' \
            ' as the number of pennies (2 digit decimal accuracy)' do
        assert_instance_of StoreAsInt::Money, 1.cents
        assert_equal 1/(100.to_d), 1.cents

        10.times do
          random_int = rand.to_s.sub(".", "").to_i
          assert_equal random_int/(1_00.to_d), random_int.cents
        end
      end

      test '#percent returns a StoreAsInt::ExchangeRate' \
            ' with a 10 digit decimal accuracy' do
        assert_instance_of StoreAsInt::ExchangeRate, 1.percent
        assert_equal StoreAsInt::ExchangeRate.new(1), 1.percent
        assert_equal 1/(1_0000000000.to_d), 1.percent

        10.times do
          random_int = rand.to_s.sub(".", "").to_i
          assert_equal random_int/(1_0000000000.to_d), random_int.percent
        end
      end
    end
  end
end
