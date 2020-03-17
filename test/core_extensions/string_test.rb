module CoreExtensions
  class StringTest < ActiveSupport::TestCase
    class MethodWasCalled < StandardError
    end

    test '#pack_hex wrap string in array and calls #pack_hex' do
      hex_was_packed = -> { raise MethodWasCalled.new('PACKED') }
      assert_raises(MethodWasCalled, 'PACKED') do
        Array.stub_instances(:pack_hex, hex_was_packed) do
          "".pack_hex
        end
      end

      val = "random value #{rand}"
      assert_equal [val].pack_hex, val.pack_hex

      generated = JsonWebToken.gen_encryption_key
      assert_equal [generated].pack_hex, generated.pack_hex
    end

    test "#unpack_binary calls unpack with 'H*'" do
      ensure_args = ->(*args) do
        assert_equal 1, args.length
        assert_equal 'H*', args.first
      end
      String.stub_instances(:unpack, ensure_args) do
        "".unpack_binary
      end

      generated_hex = JsonWebToken.gen_encryption_key.pack_hex

      assert_equal generated_hex.unpack('H*'), generated_hex.unpack_binary
    end
  end
end
