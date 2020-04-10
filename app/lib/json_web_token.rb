# encoding: utf-8
# frozen_string_literal: true

require 'jwt'
require 'jwe'
require 'openssl'
require 'active_support/concern'

class JsonWebToken
  CHARACTERS = [
    *('a'..'z'),
    *('A'..'Z'),
    *(0..9).map(&:to_s),
    *'!@#$%^&*()'.split('')
  ].freeze

  DEFAULT_OPTIONS = { enc:  'A256GCM', alg: 'dir', zip: 'DEF' }.freeze

  class << self
    def decode(payload, sig_key = nil, enc_key = nil)
      sig_key ||= signing_key
      enc_key ||= encryption_key
      decrypted = ::JWE.decrypt(payload, enc_key)

      ::JWT.decode(decrypted, sig_key, true, algorithm: 'HS512')[0]
    end
    alias_method :read, :decode
    alias_method :decrypt, :decode
    alias_method :deflate, :decode

    def default_encryption_key
      get_encryption_key_from_credentials ||
      gen_encryption_key
    end

    def default_signing_key
      get_signing_key_from_credentials ||
      gen_signing_key
    end

    def encode(payload, sig_key = nil, enc_key = nil, options = nil)
      sig_key ||= signing_key
      enc_key ||= encryption_key
      options ||= encrypt_options
      encoded = ::JWT.encode(payload, sig_key, 'HS512')

      ::JWE.encrypt(encoded, enc_key, **options)
    end
    alias_method :create, :encode
    alias_method :encrypt, :encode
    alias_method :inflate, :encode

    def encrypt_options
      @encrypt_options ||= DEFAULT_OPTIONS
    end

    def encrypt_options=(options)
      @encrypt_options = (options || DEFAULT_OPTIONS)
    end

    def encryption_key
      @encryption_key ||= default_encryption_key
    end

    def encryption_key=(key)
      @encryption_key = (key || gen_encryption_key)
    end

    def gen_encryption_key
      SecureRandom.random_bytes(32)
    end

    def gen_signing_key(length = 50)
      (0...length).map { CHARACTERS[rand(CHARACTERS.length)] }.join
    end

    def signing_key
      @signing_key ||= default_signing_key
    end

    def signing_key=(key)
      @signing_key = (key || gen_signing_key)
    end

    private
      def get_encryption_key_from_credentials
        Rails.
          application.
          credentials.
          dig(:jwt, :encryption_key_hex).
          presence&.pack_hex
      end

      def get_signing_key_from_credentials
        Rails.application.credentials.dig(:jwt, :signing_key).presence
      end
  end
end
