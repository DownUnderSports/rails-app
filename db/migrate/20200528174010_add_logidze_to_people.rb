class AddLogidzeToPeople < ActiveRecord::Migration[5.0]
  require 'logidze/migration'
  include Logidze::Migration

  def up

    add_column :people, :log_data, :jsonb


    execute <<-SQL
      CREATE TRIGGER logidze_on_people
      BEFORE UPDATE OR INSERT ON people FOR EACH ROW
      WHEN (coalesce(#{current_setting('logidze.disabled')}, '') <> 'on')
      EXECUTE PROCEDURE logidze_logger(20, 'updated_at');
    SQL


  end

  def down

    execute "DROP TRIGGER IF EXISTS logidze_on_people on people;"


    remove_column :people, :log_data


  end
end
