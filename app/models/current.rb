# encoding: utf-8
# frozen_string_literal: true

# Current description
class Current < ActiveSupport::CurrentAttributes
  # == Constants ============================================================

  # == Extensions ===========================================================

  # == Attributes ===========================================================
  attribute :session
  attribute :request_id, :browser_id, :user_agent, :ip_address

  # == Attachments ==========================================================

  # == Relationships ========================================================

  # == Validations ==========================================================

  # == Scopes ===============================================================

  # == Callbacks ============================================================

  # == Boolean Class Methods ================================================

  # == Class Methods ========================================================

  # == Boolean Methods ======================================================

  # == Instance Methods =====================================================
  def user
    self.session&.user
  end

  def user_id
    self.session&.user_id
  end

  # == Private Methods ======================================================

end
