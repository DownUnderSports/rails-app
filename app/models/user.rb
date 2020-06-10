# encoding: utf-8
# frozen_string_literal: true

# User description
class User < ApplicationRecord
  # == Constants ============================================================
  CATEGORIES = %w[ athlete coach guide official staff supporter ].freeze

  # == Extensions ===========================================================
  include LiberalEnum

  # == Attributes ===========================================================
  has_logidze
  nacl_password skip_validations: :blank
  nacl_password :single_use, skip_validations: true

  enum category: self::CATEGORIES.to_db_enum, _suffix: true
  liberal_enum :category

  # == Relationships ========================================================
  has_many :sessions, inverse_of: :user
  has_many :sport_backgrounds, inverse_of: :user

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

  # == Instance Methods =====================================================
  def password_reset
    key = self.single_use = generate_password_reset_token
    self.single_use_expires_at = 1.hour.from_now
    key
  end

  def password_reset!
    key = password_reset
    save!
    key
  end

  # == Private Methods ======================================================
  private
    def generate_password_reset_token
      RbNaCl::Random.random_bytes(64).unpack_binary
    end

end
