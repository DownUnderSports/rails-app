class HelperFunctions < ActiveRecord::Migration[6.0]
  def up
    function_names.each do |f|
      execute File.read(Rails.root.join('db', 'sql', 'functions', "#{f}.psql"))
    end
  end

  def down
    function_names.reverse.each do |f|
      execute "DROP FUNCTION IF EXISTS #{f}();"
    end
  end

  private
    def function_names
      %w[
        temp_table_exists
        hash_password
        validate_email
        valid_email_trigger
        unique_random_string
      ]
    end
end
