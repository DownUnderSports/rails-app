require 'minitest/mock'
require 'test_helper'

# Create a temporary duplicate class to avoid messing up other tests
TJsonWebToken = Class.new(JsonWebToken)

class JsonWebTokenTest < ActiveSupport::TestCase
  def setup
    TJsonWebToken.signing_key = nil
    TJsonWebToken.encryption_key = nil
    TJsonWebToken.encrypt_options = nil
    @unique_tries = Boolean.parse(ENV['FULL']) ? 100000 : 100
  end

  def assert_is_getter(mthd, inst_v = nil)
    inst_v ||= :"@#{mthd}"
    refute_nil TJsonWebToken.__send__(mthd)
    refute_nil TJsonWebToken.instance_variable_get(inst_v)
    assert_equal TJsonWebToken.instance_variable_get(inst_v), TJsonWebToken.__send__(mthd)
  end

  def assert_is_setter(mthd, inst_v = nil, &block)
    inst_v ||= :"@#{mthd.sub("=", '')}"

    10.times do
      val = block.call

      refute_equal val, TJsonWebToken.instance_variable_get(inst_v)

      TJsonWebToken.__send__(mthd, val)

      assert_equal val, TJsonWebToken.instance_variable_get(inst_v)
    end
  end

  def sample_data
    { data: 'stuff' }
  end


  test '.gen_encryption_key creates a random 32 byte string' do
    key = TJsonWebToken.gen_encryption_key
    keys = { "#{key}" => true }

    assert_instance_of String, TJsonWebToken.gen_encryption_key
    assert_equal 32, TJsonWebToken.gen_encryption_key.size

    @unique_tries.times do
      k = TJsonWebToken.gen_encryption_key
      refute_equal key, k
      assert_equal 32, k.size
      refute keys[k]
      keys[k] = true
      key = k
    end
    keys = nil
  end

  test ".default_encryption_key gets a value from credentials if available" do
    Rails.application.credentials.stub(:dig, "tmp_value".unpack('H*')) do
      assert_equal "tmp_value", TJsonWebToken.default_encryption_key
    end
  end

  test ".default_encryption_key generates a new key if credentials empty" do
    TJsonWebToken.stub(:gen_encryption_key, "tmp_value") do
      Rails.application.credentials.stub(:dig, nil) do
        assert_equal "tmp_value", TJsonWebToken.default_encryption_key
      end
    end
  end

  test '.gen_signing_key creates a random string' do
    key = TJsonWebToken.gen_signing_key
    keys = { key => true }

    assert_instance_of String, TJsonWebToken.gen_signing_key

    @unique_tries.times do
      k = TJsonWebToken.gen_signing_key
      refute_equal key, k
      refute keys[k]
      keys[k] = true
      key = k
    end
    keys = nil
  end

  test '.gen_signing_key defaults to 50 characters' do
    assert_equal 50, TJsonWebToken.gen_signing_key.size
  end

  test '.gen_signing_key accepts a param to set a string length' do
    100.times do
      len = rand(1000)
      assert_equal len, TJsonWebToken.gen_signing_key(len).size
    end
  end

  test ".default_signing_key gets a value from credentials if available" do
    Rails.application.credentials.stub(:dig, "tmp_value") do
      assert_equal "tmp_value", TJsonWebToken.default_signing_key
    end
  end

  test ".default_signing_key generates a new key if credentials empty" do
    TJsonWebToken.stub(:gen_signing_key, "tmp_value") do
      Rails.application.credentials.stub(:dig, nil) do
        assert_equal "tmp_value", TJsonWebToken.default_signing_key
      end
    end
  end

  [
    'encryption_key',
    'signing_key'
  ].each do |mthd|
    inst_v = :"@#{mthd}"
    test ".#{mthd} is a getter for @#{mthd}" do
      assert_is_getter mthd, inst_v
    end

    test ".#{mthd} sets a new key if empty" do
      old_key = TJsonWebToken.__send__(mthd)
      TJsonWebToken.instance_variable_set(inst_v, nil)

      assert_nil TJsonWebToken.instance_variable_get(inst_v)

      new_key = TJsonWebToken.__send__(mthd)

      refute_equal old_key, new_key
      refute_nil TJsonWebToken.instance_variable_get(inst_v)
      assert_equal new_key, TJsonWebToken.instance_variable_get(inst_v)
    end

    test ".#{mthd} uses .default_#{mthd} to set empty values" do
      TJsonWebToken.instance_variable_set(inst_v, nil)
      assert_nil TJsonWebToken.instance_variable_get(inst_v)
      TJsonWebToken.stub(:"default_#{mthd}", "tmp_value") do
        assert_equal "tmp_value", TJsonWebToken.__send__(mthd)
      end
    end

    test ".#{mthd}= is an setter for @#{mthd}" do
      assert_is_setter("#{mthd}=", inst_v) do
        TJsonWebToken.__send__("gen_#{mthd}")
      end
    end

    test ".#{mthd}= generates a new key if nil" do
      old_key = TJsonWebToken.__send__(mthd)

      TJsonWebToken.__send__("#{mthd}=", nil)

      new_key = TJsonWebToken.instance_variable_get(inst_v)

      refute_nil new_key
      refute_equal old_key, new_key
    end
  end

  test ".encrypt_options is a getter for @encrypt_options" do
    assert_is_getter :encrypt_options
  end

  test ".encrypt_options reverts to default if empty" do
    TJsonWebToken.instance_variable_set(:@encrypt_options, nil)

    assert_nil TJsonWebToken.instance_variable_get(:@encrypt_options)
    refute_nil TJsonWebToken.encrypt_options
    assert_equal TJsonWebToken::DEFAULT_OPTIONS, TJsonWebToken.encrypt_options
    assert_equal TJsonWebToken.encrypt_options, TJsonWebToken.instance_variable_get(:@encrypt_options)
  end

  test ".encrypt_options= is a setter for @encrypt_options" do
    assert_is_setter("encrypt_options=") do
      TJsonWebToken::CHARACTERS.map do
        TJsonWebToken::CHARACTERS[rand(TJsonWebToken::CHARACTERS.size)]
      end
    end
  end

  test ".encrypt_options= reverts to default if empty" do
    TJsonWebToken.encrypt_options = nil
    refute_nil TJsonWebToken.instance_variable_get(:@encrypt_options)
    assert_equal TJsonWebToken::DEFAULT_OPTIONS, TJsonWebToken.encrypt_options
  end

  test ".encode encrypts a JWE with .encryption_key and a JWT payload signed by .signing_key" do
    encoded = TJsonWebToken.encode(sample_data)
    assert_equal 5, encoded.split('.').size
    assert_match /[^\.]+\.[^\.]*(\.[^\.]+){3}/, encoded
    assert_nothing_raised do
      ::JWE.decrypt(
        TJsonWebToken.encode(sample_data),
        TJsonWebToken.encryption_key
      )
    end
    assert_raises(::JWE::InvalidData) do
      ::JWE.decrypt(
        TJsonWebToken.encode(sample_data),
        TJsonWebToken.gen_encryption_key
      )
    end
  end

  test ".encode uses direct encryption" do
    assert_equal 0, TJsonWebToken.encode(sample_data).split('.')[1].size
  end

  test ".encode is decodable" do
    assert_nothing_raised do
      TJsonWebToken.decode(TJsonWebToken.encode(sample_data))
    end

    assert_raises(::JWE::InvalidData) do
      TJsonWebToken.decode(
        TJsonWebToken.encode(
          sample_data,
          nil,
          TJsonWebToken.gen_encryption_key
        )
      )
    end

    assert_raises(::JWT::VerificationError) do
      TJsonWebToken.decode(
        TJsonWebToken.encode(
          sample_data,
          TJsonWebToken.gen_signing_key
        )
      )
    end


    decoded = TJsonWebToken.decode(TJsonWebToken.encode(sample_data))
    assert decoded
    assert_instance_of Hash, decoded
    decoded.keys.each do |k|
      assert_instance_of String, k
    end
    assert_equal sample_data.keys.map(&:to_s), decoded.keys
  end



  test ".decode retrieves a JWT payload signed by .signing_key from a JWE encrypted with .encryption_key" do
    signing_key = TJsonWebToken.gen_signing_key
    encryption_key = TJsonWebToken.gen_encryption_key
    encoded_sample_data =
      TJsonWebToken.encode(
        {data: 'stuff'},
        signing_key,
        encryption_key
      )

    decoded = nil

    assert_nothing_raised do
      decoded = TJsonWebToken.decode(encoded_sample_data, signing_key, encryption_key)
    end

    assert_raises(::JWE::InvalidData) do
      TJsonWebToken.decode(
        encoded_sample_data,
        signing_key,
        TJsonWebToken.gen_encryption_key
      )
    end

    force_decoded =
      ::JWT.decode(
        ::JWE.decrypt(
          encoded_sample_data,
          encryption_key
        ),
        signing_key,
        true,
        algorithm: 'HS512'
      ).first
    assert_equal force_decoded, decoded
  end

  [
    :create,
    :encrypt,
    :inflate
  ].each do |mthd|
    test ".#{mthd} is an alias for encode" do
      assert_equal TJsonWebToken.method(:encode), TJsonWebToken.method(mthd)
    end
  end

  [
    :read,
    :decrypt,
    :deflate
  ].each do |mthd|
    test ".#{mthd} is an alias for decode" do
      assert_equal TJsonWebToken.method(:decode), TJsonWebToken.method(mthd)
    end
  end
end
