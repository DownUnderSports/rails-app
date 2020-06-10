# encoding: utf-8
# frozen_string_literal: true

# User::SportBackground description
class User < ApplicationRecord
  class SportBackground < ApplicationRecord
    # == Constants ============================================================

    # == Attributes ===========================================================
    has_logidze

    # == Extensions ===========================================================

    # == Relationships ========================================================
    belongs_to :user, required: true, inverse_of: :sport_backgrounds
    belongs_to :sport, required: true, inverse_of: :backgrounds

    # == Validations ==========================================================

    # == Scopes ===============================================================

    # == Callbacks ============================================================

    # == Boolean Class Methods ================================================

    # == Class Methods ========================================================

    # == Boolean Methods ======================================================

    # == Instance Methods =====================================================

  end
end
