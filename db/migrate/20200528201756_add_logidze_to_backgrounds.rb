class AddLogidzeToBackgrounds < ActiveRecord::Migration[5.0]
  require 'logidze/migration'
  include Logidze::Migration

  def up

    add_column :backgrounds, :log_data, :jsonb


    execute <<-SQL
      CREATE TRIGGER logidze_on_backgrounds
      BEFORE UPDATE OR INSERT ON backgrounds FOR EACH ROW
      WHEN (coalesce(#{current_setting('logidze.disabled')}, '') <> 'on')
      EXECUTE PROCEDURE logidze_logger(null, 'updated_at');
    SQL


  end

  def down
    execute "DROP TRIGGER IF EXISTS logidze_on_backgrounds on backgrounds;"
    remove_column :backgrounds, :log_data
  end
end
