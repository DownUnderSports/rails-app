# encoding: utf-8
# frozen_string_literal: true

# User description
class Person < ApplicationRecord
  # == Constants ============================================================
  CATEGORIES = %w[ athlete coach guide official staff supporter ].freeze

  PASSWORD_COLUMNS =
    %w[ password_digest single_use_digest single_use_expires_at ].freeze

  # == Extensions ===========================================================
  include LiberalEnum

  # == Attributes ===========================================================
  has_logidze
  enum category: self::CATEGORIES.to_db_enum, _suffix: true
  liberal_enum :category

  attr_readonly *PASSWORD_COLUMNS


  # == Relationships ========================================================
  has_many :backgrounds, inverse_of: :person

  # == Validations ==========================================================
  validates_presence_of :first_names, :last_names
  validates_uniqueness_of :email
  validates :category, presence: true, inclusion: {
                                                    in: self::CATEGORIES,
                                                    allow_blank: true,
                                                    message: "is not recognized"
                                                  }

  # == Scopes ===============================================================

  # == Callbacks ============================================================

  # == Boolean Class Methods ================================================

  # == Class Methods ========================================================

  # == Boolean Methods ======================================================
  def readonly?
    self.class != real_class
  end

  # == Instance Methods =====================================================
  def user
    self.becomes(User)
  end

  def real_class
    self.category.classify.constantize
  rescue
    Person
  end

  def real_instance
    self.becomes(real_class)
  rescue
    self
  end


  # == Private Methods ======================================================

end
