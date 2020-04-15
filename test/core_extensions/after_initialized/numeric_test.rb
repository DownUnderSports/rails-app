module CoreExtensions
  module AfterInitialized
    class NumericTest < ActiveSupport::TestCase
      test '#min_max returns a number between two inclusive numbers' do
        assert_equal 0.1, -1.min_max(0.1, 10)
        assert_equal -0.1, -1.min_max(-0.1, 10)
        assert_equal 1.2, -1.0.min_max(1.2, 10)
        assert_equal 10.0, 10.2.min_max(1.2, 10)
        assert_equal 1.0, 1.0.min_max(0.to_d, 10.to_f)
        assert_equal 5, 5.min_max(0, 10)
        assert_equal 5.to_d, 5.5.to_d.min_max(0.to_d, 5.to_d)
        assert_equal 10, 100.min_max(0, 10)
        assert_equal -1, -1.min_max(-10, 10)
        assert_equal 10, 100.min_max(-10, 10)
        assert_equal 10, 10.min_max(-10, 10)
      end
    end
  end
end
