# encoding: utf-8
# frozen_string_literal: true

class HomeController < ApplicationController
  # == Modules ============================================================

  # == Class Methods ======================================================

  # == Pre/Post Flight Checks =============================================

  # == Actions ============================================================
  def show
  end

  def not_found
    @errors = [ "Requested Page Not Found" ]
    return render :show
  end

  # == Cleanup ============================================================

  # == Utilities ==========================================================

end
