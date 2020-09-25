require "test_helper"

module CoreExtensions
  class StringTest < ActiveSupport::TestCase
    class MethodWasCalled < StandardError
    end

    test "#pack_hex wrap string in array and calls #pack_hex" do
      hex_was_packed = -> { raise MethodWasCalled.new("PACKED") }
      assert_raises(MethodWasCalled, "PACKED") do
        Array.stub_instances(:pack_hex, hex_was_packed) do
          "".pack_hex
        end
      end

      val = "random value #{rand}"
      assert_equal [val].pack_hex, val.pack_hex

      generated = SecureWebToken.gen_encryption_key
      assert_equal [generated].pack_hex, generated.pack_hex
    end

    test "#unpack_binary calls unpack with \"H*\" and returns the unpacked string" do
      ensure_args = ->(*args) do
        assert_equal 1, args.length
        assert_equal "H*", args.first
        ["stubbed_string"]
      end
      String.stub_instances(:unpack, ensure_args) do
        assert_equal "stubbed_string", "".unpack_binary
      end

      generated_hex = SecureWebToken.gen_encryption_key.pack_hex

      assert_equal generated_hex.unpack("H*").first, generated_hex.unpack_binary
    end
  end
end
