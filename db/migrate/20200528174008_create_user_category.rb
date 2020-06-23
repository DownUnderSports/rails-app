class CreateUserCategory < ActiveRecord::Migration[6.0]
  def change
    reversible do |d|
      d.up do
        execute <<-SQL
          DO $$
            BEGIN
              IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_category') THEN
                CREATE TYPE user_category
                  AS ENUM (
                    'athlete',
                    'coach',
                    'guide',
                    'official',
                    'staff',
                    'supporter'
                  );
              END IF;
            END
          $$;
        SQL
      end

      d.down do
        execute <<-SQL
          DROP TYPE IF EXISTS user_category;
        SQL
      end
    end
  end
end
