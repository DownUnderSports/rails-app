# encoding: utf-8
# frozen_string_literal: true

module SecureServable
  # == Constants ==========================================================
  VALID_VERBS = %w[ GET POST PATCH PUT DELETE OPTIONS HEAD ].freeze

  # == Modules ============================================================
  extend ActiveSupport::Concern

  # == Class Methods ======================================================
  class_methods do
    def not_authorized_error
      Pundit::NotAuthorizedError
    end
  end

  # == Pre/Post Flight Checks =============================================
  included do
    before_action :protocol_check
    before_action :filter_http_verbs
    before_action :set_language
    before_action :set_session_values

    rescue_from not_authorized_error, with: :not_authorized
    rescue_from ActiveRecord::RecordNotFound, with: :rescue_action_in_public
    rescue_from Net::ProtocolError, with: :redirect_to_https
  end

  # == Actions ============================================================

  # == Cleanup ============================================================

  # == Utilities ==========================================================

  private
    def cookie_expires_default
      Time.zone.now + 24.hours
    end

    def cookie_secure_default
      Rails.env.production?
    end

    def get_cookie_type(type)
      case type&.to_sym
      when :plain
      when :signed
        cookies.signed
      else
        cookies.encrypted
      end
    end

    def cookie_domain
      Rails.env.production? ? '.downundersports.com' : '.lvh.me'
    end

    def set_cookie(
                    key:,
                    value:,
                    type: :encrypted,
                    secure: cookie_secure_default,
                    expires: cookie_expires_default
                  )
      type = get_cookie_type(type)

      type[key] = {
        value: value,
        secure: Rails.env.production?,
        domain: cookie_domain,
        expires: Time.zone.now + 24.hours
      }
    end

    def delete_cookie(key:, type: :encrypted)
      type = get_cookie_type(type)
      type.delete key, domain: cookie_domain
    end

    def filter_http_verbs
      unless VALID_VERBS.include?(request.method)
        raise http_method_not_allowed
      end
    end

    def http_method_not_allowed
      ActionController::MethodNotAllowed.
        new("#{request.method} http request method not allowed")
    end

    def not_authorized_error
      self.class.not_authorized_error
    end

    def not_authorized(errors = nil, status = 401)
      errors = case errors
      when not_authorized_error, nil
        [ 'You are not authorized to perform the requested action' ]
      when String
        [
          errors
        ]
      else
        errors
      end

      return render json: { errors: errors }, status: status
    end

    def protocol_check
      unless (request.ssl? || request.local?)
        raise Net::ProtocolError
      end
    end

    def rescue_action_in_public(exception)
      case exception
      when  ActiveRecord::RecordNotFound,
            ActionController::UnknownAction,
            ActionController::RoutingError
        return render 'shared/not_found', layout: true, status: 404
      else
        super
      end
    end

    def redirect_to_https
      redirect_to protocol: "https://"
    end

    def set_language
      response.headers["Content-Language"] = "en-US, en"
    end

    def set_session_values
      device_id
    end

    def device_id
      session[:device_id] ||= SecureRandom.uuid
    end
end
