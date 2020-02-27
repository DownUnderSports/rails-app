class AuditFunctions < ActiveRecord::Migration[6.0]
  def up
    execute File.read(Rails.root.join('db', 'sql', 'auditing', '91plus-audit-table.psql'))
    execute File.read(Rails.root.join('db', 'sql', 'auditing', '91plus-audit-trigger.psql'))
  end

  def down
    execute "DROP SCHEMA IF EXISTS auditing CASCADE"
  end
end
