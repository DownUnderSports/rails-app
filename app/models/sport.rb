# encoding: utf-8
# frozen_string_literal: true

# Sport description
class Sport < ApplicationRecord
  # == Constants ============================================================

  # == Extensions ===========================================================

  # == Attributes ===========================================================
  has_logidze

  # == Relationships ========================================================
  has_many :backgrounds, inverse_of: :sport

  # == Validations ==========================================================

  # == Scopes ===============================================================

  # == Callbacks ============================================================

  # == Boolean Class Methods ================================================

  # == Class Methods ========================================================

  # == Boolean Methods ======================================================

  # == Instance Methods =====================================================

  # == Private Methods ======================================================

end