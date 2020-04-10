class ApplicationController < ActionController::Base
  # == Constants ==========================================================

  # == Modules ============================================================
  include Pundit
  include SecureServable
  helper DateHelper

  # == Class Methods ======================================================

  # == Pre/Post Flight Checks =============================================

  # == Actions ============================================================
  def version
    render plain: DownUnderSports::VERSION
  end

  def index
  end

  # == Cleanup ============================================================

  # == Utilities ==========================================================
end
