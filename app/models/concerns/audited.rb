module Audited
  extend ActiveSupport::Concern

  class_methods do
    def set_audit_methods!
      begin
        t_name = "auditing.logged_actions_#{self.table_name_only}"
        connection.execute(%Q(SELECT 1 FROM #{t_name} LIMIT 1))

        self.const_set(:LoggedAction, Class.new(Auditing::LoggedActionBase))
        self.const_get(:LoggedAction).table_name = t_name
        self.const_get(:LoggedAction).primary_key = :event_id
      rescue ActiveRecord::StatementInvalid
        self.const_set(:LoggedAction, Auditing::LoggedAction)
      end

      self.has_many :logged_actions,
        class_name: "#{self.to_s}::LoggedAction",
        primary_type: :table_name_with_schema,
        foreign_key: :row_id,
        foreign_type: :full_name,
        as: :logged_actions

      self
    rescue ActiveRecord::NoDatabaseError
      self
    end

    def revert_to_action!(event_id, record = nil)
      transaction do
        target_action = get_valid_action! event_id, record

        new_attrs, was_destroyed =
          get_reverted_changes_attributes(target_action)

        if was_destroyed
          create! new_attrs
        else
          (record ||= target_action.audited).update! new_attrs
          record
        end
      end
    end

    def get_valid_action!(event_id, record = nil)
      (
        record ||
        LoggedAction.
          where(full_name: table_name_with_schema)
      ).
      find_by(event_id: event_id) || raise("Not a Valid Action")
    end

    def get_reverted_changes_attributes(target_action)
      new_attrs = was_destroyed = false

      logged_actions.
        since_event(event_id).
        rewinding.
        split_batches_values(preserve_order: true) do |action|
          new_attrs, did_destroy =
            merge_logged_action_changes(action, new_attrs)
          was_destroyed ||= did_destroy
        end

      new_attrs, did_destroy =
        merge_logged_action_changes(target_action, new_attrs)

      [ new_attrs, (was_destroyed || did_destroy) ]
    end

    def merge_logged_action_changes(action, new_attrs = {})
      new_attrs = {} unless new_attrs.is_a? Hash

      if action.action == 'D'
        [ action.row_data.dup.symbolize_keys, true ]
      else
        action.changed_fields.each do |k, _|
          new_attrs[k.to_sym] = action[k]
        end
        [ new_attrs, false ]
      end
    end
  end

  def revert_to_action!(event_id)
    self.class.revert_to_action! event_id, self
  end
end
