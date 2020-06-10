# encoding: utf-8
# frozen_string_literal: true

class Authenticator
  # == Constants ============================================================

  # == Attributes ===========================================================
  attr_accessor :controller
  attr_accessor :domain
  private :controller, :controller=, :domain, :domain=

  # == Extensions ===========================================================
  delegate :new_session_url, :redirect_to, to: :controller, private: true

  # == Relationships ========================================================

  # == Validations ==========================================================

  # == Scopes ===============================================================

  # == Callbacks ============================================================

  # == Boolean Class Methods ================================================

  # == Class Methods ========================================================

  # == Boolean Methods ======================================================
  def session_outdated?
    (current_session&.updated_at || Time.zone.now) < 1.hour.ago
  end

  def logged_in?
    CoerceBoolean.from(current_session, strict: true)
  end

  def logged_out?
    !CoerceBoolean.from(current_session, strict: true) &&
    CoerceBoolean.from(@logged_in, strict: true)
  end

  # == Instance Methods =====================================================
  def initialize(current_controller:, cookie_domain: nil)
    self.controller = current_controller

    self.domain =
      cookie_domain ||
      (Rails.env.production? ? '.downundersports.com' : :all)

    set_current_information

    self
  end

  def browser_id
    @browser_id ||= get_browser_id
  end

  def current_session
    Current.session
  end

  def current_session=(session)
    Current.session = session
    set_session_cookies
    Current.session
  end

  def current_user
    Current.user
  end

  def login(user)
    attrs = session_attributes

    user.
      sessions.
      where(browser_id: attrs[:browser_id]).
      destroy_all

    self.current_session = user.sessions.create!(attrs)
  end

  def logout(record = nil)
    record&.destroy
    Current.session = nil
    cookies.delete :session_id, domain: domain, tld_length: 2
    cookies.delete :session_token, domain: domain, tld_length: 2
    @logged_out = true
    nil
  end

  def require_authentication
    return redirect_to new_session_url unless logged_in?
  end

  private
    def cookies
      controller.request.cookie_jar
    end

    def find_session
      set_request_information unless Current.request_id
      record = User::Session.find_by(id: cookies.encrypted[:session_id])
      if record&.allowed?
        record
      else
        logout(record)
      end
    end

    def get_browser_id
      set_browser_id cookies.encrypted[:browser_id].presence
      cookies.encrypted[:browser_id]
    end

    def get_existing_session
      Current.session = find_session
      update_current_token
      current_session
    end

    def request
      controller.request
    end

    def remote_ip
      request.remote_ip.presence || request.ip
    rescue
      request.ip
    end

    def session_attributes
      {
        token: "#{Current.user_agent}:#{Current.ip_address}:#{Current.browser_id}",
        user_agent: Current.user_agent,
        ip_address: Current.ip_address,
        browser_id: Current.browser_id
      }
    end

    def set_browser_id(existing_value = nil)
      cookies.encrypted[:browser_id] = {
        value: (existing_value.presence || SecureRandom.uuid),
        expires: Time.now + 90.days,
        secure: Rails.env.production?,
        domain: domain,
        tld_length: 2
      }
    end

    def set_current_information
      set_request_information
      get_existing_session
    end

    def set_request_information
      Current.request_id = request.uuid
      Current.browser_id = browser_id
      Current.user_agent = request.user_agent
      Current.ip_address = remote_ip
    end

    def set_session_cookies
      if current_session
        current_session.touch
        cookies.encrypted[:session_id] = {
          value: current_session.id,
          expires: Time.now + 24.hours,
          secure: Rails.env.production?,
          domain: domain,
          tld_length: 2
        }
      else
        logout
      end
    end

    def update_current_token
      set_session_cookies if session_outdated?
    end
end
