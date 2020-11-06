# encoding: utf-8
# frozen_string_literal: true

# Sport description
class Sport < ApplicationRecord
  # == Constants ============================================================

  # == Extensions ===========================================================

  # == Attributes ===========================================================
  data_column_attribute :test_id, :integer

  # == Attachments ==========================================================

  # == Relationships ========================================================
  has_many :backgrounds, inverse_of: :sport

  # == Validations ==========================================================
  validates_presence_of :abbr, :name

  validates :abbr_gendered, :name_gendered,
    uniqueness: true,
    presence:   true

  # == Scopes ===============================================================

  # == Callbacks ============================================================

  # == Boolean Class Methods ================================================

  # == Class Methods ========================================================

  # == Boolean Methods ======================================================

  # == Instance Methods =====================================================

  # == Private Methods ======================================================

end
