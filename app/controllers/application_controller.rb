class ApplicationController < ActionController::Base
  # == Modules ============================================================
  include Authenticated
  helper GridHelper
  helper WebpackerOverrides

  # == Class Methods ======================================================

  # == Pre/Post Flight Checks =============================================

  # == Actions ============================================================

  # == Cleanup ============================================================

  # == Utilities ==========================================================

end
