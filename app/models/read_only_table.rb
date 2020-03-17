class ReadOnlyTable < ApplicationRecord
  # == Constants ============================================================

  # == Attributes ===========================================================
  self.abstract_class = true

  # == Extensions ===========================================================

  # == Relationships ========================================================

  # == Validations ==========================================================

  # == Scopes ===============================================================

  # == Callbacks ============================================================

  # == Boolean Class Methods ================================================

  # == Class Methods ========================================================
  def readonly?
    true
  end

  def delete
    false
  end

  def delete!
    raise ActiveRecord::ReadOnlyRecord, "#{self.class} is marked as readonly"
  end

  # == Boolean Methods ======================================================

  # == Instance Methods =====================================================

end
