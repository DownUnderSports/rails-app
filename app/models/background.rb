# encoding: utf-8
# frozen_string_literal: true

# Background description
class Background < ApplicationRecord
  # == Constants ============================================================

  # == Attributes ===========================================================
  has_logidze

  # == Extensions ===========================================================

  # == Relationships ========================================================
  belongs_to :person, required: true, inverse_of: :backgrounds
  belongs_to :sport, required: false, inverse_of: :backgrounds

  # == Validations ==========================================================

  # == Scopes ===============================================================

  # == Callbacks ============================================================

  # == Boolean Class Methods ================================================

  # == Class Methods ========================================================

  # == Boolean Methods ======================================================

  # == Instance Methods =====================================================

end
