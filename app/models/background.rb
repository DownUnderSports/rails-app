# encoding: utf-8
# frozen_string_literal: true

# Background description
class Background < ApplicationRecord
  # == Constants ============================================================

  # == Extensions ===========================================================
  include LiberalEnum

  # == Attributes ===========================================================
  enum category: Person::CATEGORIES.to_db_enum, _suffix: :type
  liberal_enum :category

  # == Attachments ==========================================================

  # == Relationships ========================================================
  belongs_to :person,
    required:   true,
    inverse_of: :backgrounds

  belongs_to :sport,
    required:   false,
    inverse_of: :backgrounds

  # == Validations ==========================================================
  validates :category,
    presence:   true,
    inclusion:  {
                  in: Person::CATEGORIES,
                  allow_blank: true,
                  message: "is not recognized"
                }

  validates_uniqueness_of_scope :person_id, :main,
    if:         :main?,
    message:    "only allowed for one background",
    attribute:  :main

  validates_uniqueness_of_scope :person_id, :sport_id, :category, :year

  # == Scopes ===============================================================
  scope :this_year, -> { where(year: Time.zone.now.year) }

  # == Callbacks ============================================================

  # == Boolean Class Methods ================================================

  # == Class Methods ========================================================

  # == Boolean Methods ======================================================

  # == Instance Methods =====================================================

end
