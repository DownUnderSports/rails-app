class AddLogidzeToUserSportBackgrounds < ActiveRecord::Migration[5.0]
  require 'logidze/migration'
  include Logidze::Migration

  def up

    add_column :user_sport_backgrounds, :log_data, :jsonb


    execute <<-SQL
      CREATE TRIGGER logidze_on_user_sport_backgrounds
      BEFORE UPDATE OR INSERT ON user_sport_backgrounds FOR EACH ROW
      WHEN (coalesce(#{current_setting('logidze.disabled')}, '') <> 'on')
      EXECUTE PROCEDURE logidze_logger(null, 'updated_at');
    SQL


  end

  def down
    execute "DROP TRIGGER IF EXISTS logidze_on_user_sport_backgrounds on user_sport_backgrounds;"
    remove_column :user_sport_backgrounds, :log_data
  end
end
