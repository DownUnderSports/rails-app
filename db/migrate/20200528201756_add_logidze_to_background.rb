class AddLogidzeToBackground < ActiveRecord::Migration[5.0]
  require 'logidze/migration'
  include Logidze::Migration

  def up

    add_column :background, :log_data, :jsonb


    execute <<-SQL
      CREATE TRIGGER logidze_on_background
      BEFORE UPDATE OR INSERT ON background FOR EACH ROW
      WHEN (coalesce(#{current_setting('logidze.disabled')}, '') <> 'on')
      EXECUTE PROCEDURE logidze_logger(null, 'updated_at');
    SQL


  end

  def down
    execute "DROP TRIGGER IF EXISTS logidze_on_background on background;"
    remove_column :background, :log_data
  end
end
