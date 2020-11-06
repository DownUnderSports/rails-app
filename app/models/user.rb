# encoding: utf-8
# frozen_string_literal: true

# User description
class User < Person
  # == Constants ============================================================
  WRITABLE_COLUMNS =
    (Person::PASSWORD_COLUMNS + %w[ created_at updated_at ]).freeze

  # == Extensions ===========================================================
  include ClearableReadonlyAttributes

  # == Attributes ===========================================================
  attr_readonly *(column_names.reject {|col| WRITABLE_COLUMNS.include? col })

  attr_not_readonly *WRITABLE_COLUMNS

  nacl_password skip_validations: :blank

  nacl_password :single_use, skip_validations: true

  # == Attachments ==========================================================

  # == Relationships ========================================================
  has_many :sessions, inverse_of: :user

  # == Validations ==========================================================

  # == Scopes ===============================================================

  # == Callbacks ============================================================

  # == Boolean Class Methods ================================================

  # == Class Methods ========================================================

  # == Boolean Methods ======================================================
  def readonly?
    false
  end

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
