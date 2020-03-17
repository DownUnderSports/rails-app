module CoreExtensions
  module ObjectTests
    class ClassMethodTest < ActiveSupport::TestCase
      class ::Object
        def sample_method
          "test"
        end
      end

      def add_redefinition(klass = Object)
        redefined = klass.redefine_once(:sample_method, :sample_redefined) do
          "changed"
        end

        assert redefined

        if block_given?
          begin
            yield
          ensure
            remove_redefinition
          end
        end
      end

      def redefine_again(klass = Object)
        klass.redefine_once(:sample_method, :sample_redefined) do
          "changed again"
        end
      end

      def remove_redefinition(klass = Object)
        klass.redefined_method_tags.delete :sample_redefined
        klass.remove_method :sample_method
        klass.alias_method :sample_method, :sample_redefined
        klass.remove_method :sample_redefined
      rescue
        nil
      end

      test '.redefined_method_tags returns a set for each class' do
        assert_instance_of Set, Object.redefined_method_tags
        klass = Class.new(Object)
        refute_same Object.redefined_method_tags, klass.redefined_method_tags
        assert_instance_of Set, klass.redefined_method_tags
      end

      test '.redefine_once redefines a given method' do
        add_redefinition do
          assert_equal "changed", Object.sample_method
        end
      end

      test '.redefine_once aliases a method with a given tag' do
        refute_respond_to Object, :sample_redefined

        add_redefinition do
          assert_respond_to Object, :sample_redefined

          assert_equal "test", Object.sample_redefined
          assert_equal "changed", Object.sample_method
        end
      end

      test '.redefine_once returns false if the tag has been used' do
        refute_respond_to Object, :sample_redefined

        add_redefinition

        assert_equal "changed", Object.sample_method

        response = redefine_again

        refute response
        refute_equal "changed again", Object.sample_method
        assert_equal "changed", Object.sample_method

        remove_redefinition

        response = redefine_again

        assert response
        assert_equal "changed again", Object.sample_method
        assert_equal "test", Object.sample_redefined
      ensure
        remove_redefinition
      end

      test '.redefine_once can be called again on a subclass' do
        add_redefinition
        refute redefine_again
        klass = Class.new(Object)
        assert_equal "changed", klass.new.sample_method
        assert redefine_again(klass)
        assert_equal "changed again", klass.new.sample_method
        assert_equal "changed", klass.new.sample_redefined
        remove_redefinition klass
      ensure
        remove_redefinition
      end
    end

    class InsanceMethodTest < ActiveSupport::TestCase
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
end
