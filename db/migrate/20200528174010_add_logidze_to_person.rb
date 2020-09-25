class AddLogidzeToPerson < ActiveRecord::Migration[5.0]
  require "logidze/migration"
  include Logidze::Migration

  def up
    add_column :person, :log_data, :jsonb

    execute <<-SQL
      CREATE TRIGGER logidze_on_person
      BEFORE UPDATE OR INSERT ON person FOR EACH ROW
      WHEN (coalesce(#{current_setting("logidze.disabled")}, '') <> 'on')
      EXECUTE PROCEDURE logidze_logger(20, 'updated_at','{password_digest,single_use_digest,single_use_expires_at}');
    SQL
  end

  def down
    execute "DROP TRIGGER IF EXISTS logidze_on_person on person;"

    remove_column :person, :log_data
  end
end
