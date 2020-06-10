class CreateUsers < ActiveRecord::Migration[6.0]
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

    create_table :users, id: :uuid do |t|
      t.column :category, :user_category, null: false
      t.text :title
      t.text :first_names, null: false
      t.text :middle_names
      t.text :last_names, null: false
      t.text :suffix
      t.text :email
      t.text :password_digest
      t.text :single_use_digest
      t.datetime :single_use_expires_at
      t.jsonb :data, null: false, default: {}

      t.index [ :category ]
      t.index [ :email ], unique: true

      t.timestamps default: -> { 'NOW()' }
    end
  end
end
