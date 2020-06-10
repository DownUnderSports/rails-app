module Authenticated
  # == Constants ==========================================================
  AUTHENTICATOR_METHODS =
    Set[
      :current_session,
      :current_user,
      :logged_in?,
      :login,
      :logout,
      :require_authentication
    ]
  # == Modules ============================================================
  extend ActiveSupport::Concern

  included do
    before_action { set_authenticator }
  end

  delegate(*AUTHENTICATOR_METHODS, to: :authenticator, private: true)


  # == Class Methods ======================================================

  # == Pre/Post Flight Checks =============================================

  # == Actions ============================================================

  # == Cleanup ============================================================

  # == Utilities ==========================================================

  private
    def authenticator
      @authenticator
    end

    def set_authenticator
      @authenticator = Authenticator.new(
        current_controller: self,
        cookie_domain: self.cookie_domain
      )
    end

    def cookie_domain
    end
end
