module Auditing
  class CurrentUser < ActiveSupport::CurrentAttributes
    # == Constants ============================================================

    # == Attributes ===========================================================
    attribute :user, :ip_address

    # == Extensions ===========================================================

    # == Relationships ========================================================

    # == Validations ==========================================================

    # == Scopes ===============================================================

    # == Callbacks ============================================================

    # == Boolean Class Methods ================================================

    # == Class Methods ========================================================
    def self.drop_values
      self.user = nil
      self.ip_address = nil
      self
    end

    def self.set(user, ip)
      self.user = user.presence || nil
      self.ip_address = ip.presence || nil
      self
    end

    def self.user_type
      self.user ? "'#{self.user.class.polymorphic_name}'" : 'NULL'
    end

    def self.user_id
      self.user ? user.id : 'NULL'
    end

    def self.user_ip
      self.ip_address ? "'#{self.ip_address}'" : 'NULL'
    end

    # == Boolean Methods ======================================================

    # == Instance Methods =====================================================

  end
end
