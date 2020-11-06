# encoding: utf-8
# frozen_string_literal: true

# User::Session description
class User < Person
  class Session < ApplicationRecord
    # == Constants ============================================================

    # == Attributes ===========================================================
    self.table_name = "user_session"
    nacl_password :token, skip_validations: true

    # == Extensions ===========================================================

    # == Attachments ==========================================================

    # == Relationships ========================================================
    belongs_to :user,
      required:   true,
      inverse_of: :sessions

    # == Validations ==========================================================

    # == Scopes ===============================================================

    # == Callbacks ============================================================

    # == Boolean Class Methods ================================================

    # == Class Methods ========================================================

    # == Boolean Methods ======================================================
    def allowed?(token_password = nil)
      (updated_at > 24.hours.ago) &&
      !!authenticate_token(token_password || current_token)
    end

    # == Instance Methods =====================================================

    # == Private Methods ======================================================
    private
      def current_token
        Current.ip_address.present? \
          ? "#{Current.user_agent}:#{Current.ip_address}:#{Current.browser_id}" \
          : RbNaCl::Random.random_bytes(64)
      end

  end
end
