# encoding: utf-8
# frozen_string_literal: true

require 'jwt'
require 'jwe'
require 'openssl'
require 'active_support/concern'

class JSONWebToken
  CHARACTERS = [*('a'..'z'), *('A'..'Z'), *(0..9).map(&:to_s), *'!@#$%^&*()'.split('')]
  DEFAULT_OPTIONS = { enc:  'A256GCM', alg: 'dir', zip: 'DEF' }

  class << self
    def gen_encryption_key
      SecureRandom.random_bytes(32)
    end

    def encryption_key
      @encryption_key ||= gen_encryption_key
    end

    def encryption_key=(key)
      @encryption_key = key || gen_encryption_key
    end

    def gen_signing_key(length = 50)
      (0...length).map { CHARACTERS[rand(CHARACTERS.length)] }.join
    end

    def signing_key
      @signing_key ||= gen_signing_key
    end

    def signing_key=(key)
      @signing_key = key || gen_signing_key
    end

    def encrypt_options
      @encrypt_options ||= DEFAULT_OPTIONS
    end

    def encrypt_options=(options)
      @encrypt_options = options || DEFAULT_OPTIONS
    end

    def encode(payload, sig_key = nil, enc_key = nil, options = nil)
      ::JWE.encrypt ::JWT.encode(payload, (sig_key || signing_key), 'HS512'), (enc_key || encryption_key), (options || encrypt_options)
    end

    alias_method :create, :encode
    alias_method :encrypt, :encode
    alias_method :inflate, :encode

    def decode(payload, sig_key = nil, enc_key = nil)
      ::JWT.decode(::JWE.decrypt(payload, (enc_key || encryption_key)), (sig_key || signing_key), true, algorithm: 'HS512')[0]
    end

    alias_method :read, :decode
    alias_method :decrypt, :decode
    alias_method :deflate, :decode
  end

  module ControllerMethods
    extend ActiveSupport::Concern

    included do
      include ActionController::HttpAuthentication::Token::ControllerMethods
    end

    protected
      def check_user
        if logged_in?
          begin
            data = current_user_session_data
            if (data[:token_device_id] == requesting_device_id) || session[:current_user]
              if  !data[:created_at] ||
                  (data[:created_at].to_i > 24.hours.ago.to_i)
                if user = User.find_by(id: data[:user_id])
                  self.current_token = create_jwt(user, data) if data[:created_at].to_i < 1.hour.ago.to_i
                  set_user(user)
                else
                  raise 'User Not Found'
                end
              else
                raise 'Token Expired'
              end
            else
              raise "Device Does Not Match - #{data[:device_id]} || #{requesting_device_id}"
            end
          rescue
            p $!.message
            puts $!.backtrace.first(10)

            self.current_token = nil
            Auditing::CurrentUser.drop_values
          end
        end

        Auditing::CurrentUser.user || false
      end

      def create_jwt(user, additional_headers = {})
        additional_headers = {} unless additional_headers && additional_headers.is_a?(Hash)
        data = nil
        data = {
          user_id: user.id,
          created_at: Time.now.to_i,
          token_device_id: requesting_device_id
        }
        JSONWebToken.encode(data.merge(additional_headers.except(*data.keys)))
      end

      def create_session_from_certificate(cert)
        if user = get_user_from_certificate(cert)
          self.current_token = create_jwt(user, { has_certificate: true })
          set_user(user)
        end
      end

      def get_user_from_certificate(cert)
        User.
          where.not(certificate: nil).
          find_by("certificate = crypt(?, certificate)", cleaned_certificate(cert))
      end

      def cleaned_certificate(certificate)
        ensure_is_real_value(certificate)&.clean_certificate
      end

      def current_user
        Auditing::CurrentUser.user || check_user
      end

      def current_user_session_data
        logged_in? ? JSONWebToken.decode(current_token).deep_symbolize_keys : {}
      rescue
        {}
      end

      def has_correct_origin?
        true
      end

      def requesting_device_id
        if Rails.env.development?
          "development"
        else
          @requesting_device_id ||= (session[:requesting_device_id] ||= SecureRandom.uuid)
        end
      rescue
        @requesting_device_id ||= SecureRandom.uuid
      end

      def logged_in?
        current_token.present? || certificate_session_exists?
      end

      def certificate_string
        @certificate_string ||= certificate_header &&
          header_hash[certificate_header].presence
      end

      def certificate_session_exists?
        !!(
          certificate_string &&
          has_correct_origin? &&
          create_session_from_certificate(certificate_string)
        )
      end

      def current_token
        @current_token ||= authenticate_with_http_token do |token, **options|
          decrypt_token(token, options).presence
        end

        @current_token ||= session[:current_user]

        @current_token
      end

      def current_token=(value)
        @current_token = ensure_is_real_value(value)

        if @current_token
          set_auth_header
          session[:current_user] = value
        else
          unset_auth_header
          session.delete(:current_user)
        end

        @current_token
      end

      def header_hash
        @header_hash ||= request.headers.to_h.deep_symbolize_keys
      end

      def set_auth_header
        response.set_header("AUTH_TOKEN", current_token) if current_token.present?
      end

      def unset_auth_header
        response.delete_header("AUTH_TOKEN")
      end

      def decrypt_token(t, **options)
        ensure_is_real_value(t.presence)
      end

      def encrypt_token
        ensure_is_real_value(current_token.presence)
      end

      # def decrypt_token(token, options = nil, **other)
      #   value, gpg_status =
      #     ensure_is_real_value(token.presence) &&
      #     decrypt_gpg_base64(token).presence
      #
      #   puts gpg_status if Rails.env.development?
      #   value
      # rescue Exception
      # end
      #
      # def encrypt_token
      #   current_token.presence && encrypt_and_encode_str(current_token)
      # rescue Exception
      #   nil
      # end

      def set_user(user)
        Auditing::CurrentUser.set(user, get_ip_address)
      end

      def get_ip_address
        header_hash[:HTTP_X_REAL_IP] ||
        header_hash[:HTTP_CLIENT_IP] ||
        request.remote_ip
      end

      def ensure_is_real_value(value)
        (Boolean.parse(value) && (value != "nil")) ?
          value :
          nil
      end
  end
end
