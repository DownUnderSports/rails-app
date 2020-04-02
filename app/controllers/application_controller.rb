class ApplicationController < ActionController::Base
  # == Modules ============================================================
  include Pundit
  helper DateHelper

  # == Class Methods ======================================================
  def self.not_authorized_error
    Pundit::NotAuthorizedError
  end

  # == Pre/Post Flight Checks =============================================
  before_action :set_language
  before_action :filter_http_verbs
  before_action :set_values

  # == Actions ============================================================
  def version
    render plain: DownUnderSports::VERSION
  end

  def index
  end

  # == Cleanup ============================================================
  rescue_from not_authorized_error, with: :not_authorized
  rescue_from ActiveRecord::RecordNotFound, :with => :rescue_action_in_public
  rescue_from Net::ProtocolError, :with => :redirect_to_https

  private
    def filter_http_verbs
      protocol_check

      unless %w[ GET POST PATCH PUT DELETE OPTIONS HEAD ].include?(request.method)
        raise ActionController::MethodNotAllowed.new("#{request.method} http request method not allowed")
      end
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

      return render json: {
        errors: errors
      }, status: 403
    end

    def protocol_check
      unless (request.ssl? || request.local?)
        raise Net::ProtocolError
      end
    end

    def rescue_action_in_public(exception)
      case exception
      when ActiveRecord::RecordNotFound, ActionController::UnknownAction, ActionController::RoutingError
        render render html: '', layout: true, :status => 404
      else
        super
      end
    end

    def redirect_to_https
      redirect_to :protocol => "https://"
    end

    def set_language
      response.headers["Content-Language"] = "en-US, en"
    end

    def set_values
      requesting_device_id
    end
end
