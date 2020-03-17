module Auditing
  class LoggedActionBase < ReadOnlyTable
    # == Constants ============================================================
    ACTIONS = {
      D: 'DELETE',
      I: 'INSERT',
      U: 'UPDATE',
      T: 'TRUNCATE',
      A: 'ARCHIVE',
    }.with_indifferent_access

    enum action: ACTIONS.keys.to_db_enum

    # == Attributes ===========================================================
    self.abstract_class = true

    # == Extensions ===========================================================

    # == Relationships ========================================================
    belongs_to :audited,
      polymorphic:  :true,
      primary_type: :table_name_with_schema,
      foreign_key:  :row_id,
      foreign_type: :table_name,
      optional:     true

    # == Validations ==========================================================

    # == Scopes ===============================================================
    default_scope { default_order(:event_id) }

    scope :since_event, ->(event_id) do
      where(arel_table[:event_id].gt(event_id))
    end

    scope :rewinding, -> { order(event_id: :desc) }

    # == Callbacks ============================================================

    # == Boolean Class Methods ================================================

    # == Class Methods ========================================================
    def self.default_print
      [
        :event_id,
        :row_id,
        :full_name,
        :app_user_id,
        :app_user_type,
        :action_type,
        :changed_columns
      ]
    end

    # == Boolean Methods ======================================================

    # == Instance Methods =====================================================
    def changed_columns
      (self.changed_fields || {}).keys.sort.join(', ').presence || 'N/A'
    end

    def action_type
      ACTIONS[action] || 'UNKNOWN'
    end

  end
end
