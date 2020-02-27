class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  # == Constants ============================================================

  # == Attributes ===========================================================

  # == Extensions ===========================================================
  include BaseExtensions

  # == Relationships ========================================================

  # == Validations ==========================================================

  # == Scopes ===============================================================

  # == Callbacks ============================================================

  # == Boolean Class Methods ================================================

  # == Class Methods ========================================================
  def self.set_audit_methods!
    begin
      t_name = "auditing.logged_actions_#{self.table_name_only}"
      connection.execute(%Q(SELECT 1 FROM #{t_name} LIMIT 1))

      self.const_set(:LoggedAction, Class.new(ApplicationRecord))
      self.const_get(:LoggedAction).table_name = t_name
      self.const_get(:LoggedAction).primary_key = :event_id
    rescue ActiveRecord::StatementInvalid
      self.const_set(:LoggedAction, Auditing::LoggedAction)
    end

    self.has_many :logged_actions,
      class_name: "#{self.to_s}::LoggedAction",
      primary_type: :full_table_name,
      foreign_key: :row_id,
      foreign_type: :full_name,
      as: :logged_actions

    self
  rescue ActiveRecord::NoDatabaseError
    self
  end
  # == Boolean Methods ======================================================

  # == Instance Methods =====================================================

end
