module CoreExtensions
  class ArrayTest < ActiveSupport::TestCase
    test "#pack_hex calls #pack with H* as argument" do
      arr = [ "45d79595a00c9bd68e18" ]
      was_called = false
      called_with_arg = ->(arg) do
        was_called = true
        assert_equal "H*", arg
      end
      arr.stub(:pack, called_with_arg) do
        arr.pack_hex
      end
      assert was_called
      assert_equal arr.pack("H*"), arr.pack_hex
    end

    test "#to_db_enum returns a hash with each value as a key and value pair" do
      arr = %w[ one two three four ]
      hash = {
        "one" => "one",
        "two" => "two",
        "three" => "three",
        "four" => "four"
      }

      assert_equal hash, arr.to_db_enum
      arr.each {|v| assert_equal v, arr.to_db_enum[v] }
    end

    test "#to_model_enum returns a hash with each key classified" do
      arr = %w[ one two three four ]
      hash = {
        "One" => "one",
        "Two" => "two",
        "Three" => "three",
        "Four" => "four"
      }

      assert_equal hash, arr.to_model_enum
      arr.each {|v| assert_equal v, arr.to_model_enum[v.classify] }
    end
  end
end
