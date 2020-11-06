# encoding: utf-8
# frozen_string_literal: true

# Country description
class Country < ApplicationRecord
  # == Constants ============================================================

  # == Attributes ===========================================================

  # == Extensions ===========================================================

  # == Attachments ==========================================================

  # == Relationships ========================================================
  has_many :addresses, inverse_of: :country

  # == Validations ==========================================================
  validates :short, :name,
    uniqueness: true,
    presence:   true

  validates :alpha_2,
    uniqueness: true,
    presence:   true,
    format:     {
                  with: /\A[A-Z]+\Z/,
                  message: "must be only letters"
                },
    length:     {
                  is: 2,
                  message: "must be 2 characters"
                }

  validates :alpha_3,
    uniqueness: true,
    presence:   true,
    format:     {
                  with: /\A[A-Z]+\Z/,
                  message: "must be only letters"
                },
    length:     {
                  is: 3,
                  message: "must be 3 characters"
                }

  validates :numeric,
    uniqueness: true,
    presence:   true,
    format:     {
                  with: /\A[0-9]+\Z/,
                  message: "must be only numbers"
                },
    length:     {
                  is: 3,
                  message: "must be 3 characters"
                }

  # == Scopes ===============================================================

  # == Callbacks ============================================================

  # == Boolean Class Methods ================================================

  # == Class Methods ========================================================

  # == Boolean Methods ======================================================

  # == Instance Methods =====================================================
  def alpha_2=(value)
    super(value.to_s.presence&.upcase)
  end

  def alpha_3=(value)
    super(value.to_s.presence&.upcase)
  end

  def alpha_numeric=(value)
    super(value.to_s.presence)
  end

  # == Private Methods ======================================================

end
