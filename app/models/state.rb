# encoding: utf-8
# frozen_string_literal: true

# State description
class State < ApplicationRecord
  # == Constants ============================================================

  # == Attributes ===========================================================
  data_column_attribute :military, :boolean

  # == Extensions ===========================================================

  # == Attachments ==========================================================

  # == Relationships ========================================================

  # == Validations ==========================================================
  validates :abbr,
    uniqueness: true,
    presence:   true,
    format:     {
                  with: /\A[A-Z0-9]+\Z/,
                  message: "must be only letters or numbers"
                },
    length:     {
                  is: 2,
                  message: "must be 2 characters"
                }

  validates :name,
    uniqueness: true,
    presence:   true

  # == Scopes ===============================================================

  # == Callbacks ============================================================

  # == Boolean Class Methods ================================================

  # == Class Methods ========================================================

  # == Boolean Methods ======================================================

  # == Instance Methods =====================================================
  def abbr=(value)
    super(value.to_s.presence&.upcase)
  end

  # == Private Methods ======================================================

end
