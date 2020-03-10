class ApplicationController < ActionController::Base
  # == Modules ============================================================
  include JsonWebToken::ControllerMethods
  include Pundit
  include Fetchable
  helper ViewAndControllerMethods
  include ViewAndControllerMethods

  # == Class Methods ======================================================
  def self.not_authorized_error
    Pundit::NotAuthorizedError
  end

  # == Pre/Post Flight Checks =============================================
  before_action :set_language
  before_action :filter_http_verbs
  before_action :set_values
  after_action :collect_garbage, if: -> { request.format.csv? }

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
    def browser
      require 'browser'
      @browser ||= Browser.new(request.headers['HTTP_USER_AGENT'], accept_language: "en-us")
    end

    def bot_request
      browser.bot? || !!(clean_user_agent =~ /^face(bot|book)/)
    end

    def clean_user_agent
      @clean_user_agent ||= request.headers['HTTP_USER_AGENT'].to_s.strip.downcase
    end

    def collect_garbage
      GC.start
    end

    def csv_headers(file_name, deflate: true, encoding: 'utf-8', modified: Time.zone.now.ctime.to_s, disposition: 'attachment', timestamp: Time.zone.now.to_s)
      download_headers(
        file_name: file_name,
        deflate: deflate,
        encoding: encoding || 'utf-8',
        modified: modified,
        content_type: 'text/csv',
        disposition: disposition,
        timestamp: timestamp,
        extension: 'csv'
      )
    end

    def current_user_hash(minimal = false)
      u = current_user || check_user || User.new
      {
        id: u.id,
        staff: u.is_staff? ? 1 : nil,
      }.merge(
        minimal ?
          {} :
          {
            permissions: (
              u.is_staff? ?
              u.staff.attributes.symbolize_keys :
              {
                user_ids: [u.id, *u.related_users.map(&:id)],
                dus_ids: [u.dus_id, *u.related_users.map(&:dus_id)]
              }
            ),
            attributes: {
              id: u.id,
              avatar: (u.avatar.attached? ? url_for(u.avatar.variant(resize: '500x500>', auto_orient: true)) : '/mstile-310x310.png'),
              dus_id: u.dus_id,
              category: u.category_title,
              email: u.email,
              phone: u.phone,
              extension: u.extension,
              title: u.title,
              first: u.first,
              middle: u.middle,
              last: u.last,
              suffix: u.suffix,
              name: u.full_name,
              print_names: u.print_names,
              print_first_names: u.print_first_names,
              print_other_names: u.print_other_names,
              nick_name: u.nick_name,
              gender: u.gender,
              shirt_size: u.shirt_size,
            }
          }
      )
    end

    def download_headers(deflate:, content_type:, encoding:, modified:, disposition:, extension: 'csv', file_name: nil, timestamp: Time.zone.now.to_s)
      expires_now
      headers["X-Accel-Buffering"] = 'no'
      headers["Content-Type"] = "#{content_type}; charset=#{encoding}"
      headers["Content-Disposition"] = file_name ? %(#{disposition}; filename="#{file_name}#{timestamp ? "-#{timestamp}" : ''}.#{extension}") : disposition
      headers["Content-Encoding"] = 'deflate' if deflate
      headers["Last-Modified"] = modified
    end

    def filter_http_verbs
      protocol_check

      unless %w[ GET POST PATCH PUT DELETE OPTIONS HEAD ].include?(request.method)
        raise ActionController::MethodNotAllowed.new("#{request.method} http request method not allowed")
      end

    end

    def get_file_name(file)
      file.to_s.split('/').last.sub(/\.(gz|br)[^.]*?/, '')
    end

    def json_headers(deflate: true, encoding: 'utf-8', modified: Time.zone.now.ctime.to_s, content_type: 'application/json', disposition: 'inline', extension: 'json', file_name: nil, timestamp: nil)
      download_headers(
        file_name: file_name,
        deflate: deflate,
        encoding: encoding || 'utf-8',
        modified: modified,
        content_type: content_type,
        disposition: disposition,
        timestamp: timestamp,
        extension: extension
      )
    end

    def local_port
      request.port || ENV['LOCAL_PORT'] || '3100'
    end

    def local_domain
      Rails.env.development? ? "lvh.me:#{local_port}" : "downundersports.com"
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
