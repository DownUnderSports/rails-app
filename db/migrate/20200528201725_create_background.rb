class CreateBackground < ActiveRecord::Migration[6.0]
  def change
    create_table :background, id: :uuid do |t|
      t.references :person, null: false, foreign_key: true, type: :uuid
      t.column :category, :user_category, null: false
      t.references :sport, foreign_key: true, type: :uuid
      t.integer :year
      t.boolean :main, null: false, default: false
      t.jsonb :data, null: false, default: {}

      t.index [ :person_id, :main ]
      t.index [ :person_id ], unique: true,
                              name: "unique_main_background_index",
                              where: "background.main = true"

      t.index [ :person_id, :sport_id, :category, :year ], name: "background_combo_index"

      t.index [ :data ], using: :gin

      t.timestamps default: -> { "NOW()" }
    end

    reversible do |d|
      d.up do
        execute <<-SQL.squish
          CREATE UNIQUE INDEX
            unique_background_index
          ON
            public.background
          USING
            btree
          (
            person_id,
            category,
            COALESCE(sport_id, '00000000-0000-0000-0000-000000000000'),
            COALESCE(year, -1)
          )
        SQL
      end
      d.down do
        "DROP INDEX unique_background_index on public.background"
      end
    end
  end
end
