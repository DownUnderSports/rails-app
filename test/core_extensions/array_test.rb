module CoreExtensions
  class ArrayTest < ActiveSupport::TestCase
    test "#extract! removes all truthful elements in a given block" do
      arr = %w[ keep_1 remove_2 keep_3 remove_4 ]
      arr.extract! {|v| v =~ /remove/}
      assert_equal %w[ keep_1 keep_3 ], arr
    end

    test "#extract! returns the removed elements in a new array" do
      arr = %w[ keep_1 remove_2 keep_3 remove_4 ]
      removed = arr.extract! {|v| v =~ /remove/}
      assert_equal %w[ remove_2 remove_4 ], removed
    end

    test "#pack_hex calls #pack with H* as argument" do
      arr = []
      was_called = false
      called_with_arg = ->(arg) do
        was_called = true
        assert_equal arg, 'H*'
      end
      arr.stub(:pack, called_with_arg) do
        arr.pack_hex
      end
      assert was_called
    end

    test "#to_db_enum returns a hash" do
      assert_instance_of Hash, [].to_db_enum
    end

    test "#to_db_enum sets a key equal to each value" do
      arr = %w[ words stuff else ]
      assert_equal arr.sort, arr.to_db_enum.keys.sort
      arr = %i[ words stuff else ]
      assert_equal arr.sort, arr.to_db_enum.keys.sort
    end

    test "#to_db_enum sets each value as the stringified key" do
      arr = %i[ words stuff else ]
      assert (arr.to_db_enum.values.all? {|v| v.is_a? String })
      refute_equal arr.sort, arr.to_db_enum.values.sort
      assert_equal arr.sort.map(&:to_s), arr.to_db_enum.values.sort
    end
  end
end
