class AddLogidzeToSport < ActiveRecord::Migration[5.0]
  require 'logidze/migration'
  include Logidze::Migration

  def up

    add_column :sport, :log_data, :jsonb


    execute <<-SQL
      CREATE TRIGGER logidze_on_sport
      BEFORE UPDATE OR INSERT ON sport FOR EACH ROW
      WHEN (coalesce(#{current_setting('logidze.disabled')}, '') <> 'on')
      EXECUTE PROCEDURE logidze_logger(null, 'updated_at');
    SQL


  end

  def down

    execute "DROP TRIGGER IF EXISTS logidze_on_sport on sport;"


    remove_column :sport, :log_data


  end
end
