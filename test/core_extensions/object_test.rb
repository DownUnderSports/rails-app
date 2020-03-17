module CoreExtensions
  class ObjectTest < ActiveSupport::TestCase
    class InvalidConversion < StandardError
    end

    def raise_invalid_conversion
      raise InvalidConversion.new("value incorrectly converted")
    end

    def assert_converted
      assert_raises(InvalidConversion) do
        refute_converted do
          yield
        end
      end
      yield
    end

    def refute_converted
      ThreeState.stub(:convert_value, ->(*) { raise_invalid_conversion }) do
        assert_equal yield.to_s, yield
      end
    end

    test "#yes_no_to_s returns 'Yes' or 'No' for Booleans" do
      assert_converted do
        assert_equal 'Yes', true.yes_no_to_s
      end

      assert_converted do
        assert_equal 'No', false.yes_no_to_s
      end
    end

    test "#yes_no_to_s returns #to_s for non-boolean values" do
      refute_converted { nil.yes_no_to_s }
      refute_converted { 0.yes_no_to_s }
      refute_converted { "0".yes_no_to_s }
      refute_converted { :"0".yes_no_to_s }
      refute_converted { 1.yes_no_to_s }
      refute_converted { "1".yes_no_to_s }
      refute_converted { :"1".yes_no_to_s }
      refute_converted { "f".yes_no_to_s }
      refute_converted { :f.yes_no_to_s }
      refute_converted { "F".yes_no_to_s }
      refute_converted { :F.yes_no_to_s }
      refute_converted { "t".yes_no_to_s }
      refute_converted { :t.yes_no_to_s }
      refute_converted { "T".yes_no_to_s }
      refute_converted { :T.yes_no_to_s }
      refute_converted { "false".yes_no_to_s }
      refute_converted { :false.yes_no_to_s }
      refute_converted { "FALSE".yes_no_to_s }
      refute_converted { :FALSE.yes_no_to_s }
      refute_converted { "true".yes_no_to_s }
      refute_converted { :true.yes_no_to_s }
      refute_converted { "TRUE".yes_no_to_s }
      refute_converted { :TRUE.yes_no_to_s }
      refute_converted { "off".yes_no_to_s }
      refute_converted { "OFF".yes_no_to_s }
      refute_converted { :OFF.yes_no_to_s }
      refute_converted { "on".yes_no_to_s }
      refute_converted { "ON".yes_no_to_s }
      refute_converted { :ON.yes_no_to_s }
      refute_converted { "".yes_no_to_s }
      refute_converted { " ".yes_no_to_s }
      refute_converted { "\u3000\r\n".yes_no_to_s }
      refute_converted { "\u0000".yes_no_to_s }
      refute_converted { "SOMETHING RANDOM".yes_no_to_s }
    end

    test "#y_n_to_s returns 'Y' or 'N' for Booleans" do
      assert_converted do
        assert_equal 'Y', true.y_n_to_s
      end

      assert_converted do
        assert_equal 'N', false.y_n_to_s
      end
    end

    test "#y_n_to_s returns #to_s for non-boolean values" do
      refute_converted { nil.y_n_to_s }
      refute_converted { 0.y_n_to_s }
      refute_converted { "0".y_n_to_s }
      refute_converted { :"0".y_n_to_s }
      refute_converted { 1.y_n_to_s }
      refute_converted { "1".y_n_to_s }
      refute_converted { :"1".y_n_to_s }
      refute_converted { "f".y_n_to_s }
      refute_converted { :f.y_n_to_s }
      refute_converted { "F".y_n_to_s }
      refute_converted { :F.y_n_to_s }
      refute_converted { "t".y_n_to_s }
      refute_converted { :t.y_n_to_s }
      refute_converted { "T".y_n_to_s }
      refute_converted { :T.y_n_to_s }
      refute_converted { "false".y_n_to_s }
      refute_converted { :false.y_n_to_s }
      refute_converted { "FALSE".y_n_to_s }
      refute_converted { :FALSE.y_n_to_s }
      refute_converted { "true".y_n_to_s }
      refute_converted { :true.y_n_to_s }
      refute_converted { "TRUE".y_n_to_s }
      refute_converted { :TRUE.y_n_to_s }
      refute_converted { "off".y_n_to_s }
      refute_converted { "OFF".y_n_to_s }
      refute_converted { :OFF.y_n_to_s }
      refute_converted { "on".y_n_to_s }
      refute_converted { "ON".y_n_to_s }
      refute_converted { :ON.y_n_to_s }
      refute_converted { "".y_n_to_s }
      refute_converted { " ".y_n_to_s }
      refute_converted { "\u3000\r\n".y_n_to_s }
      refute_converted { "\u0000".y_n_to_s }
      refute_converted { "SOMETHING RANDOM".y_n_to_s }
    end
  end
end
