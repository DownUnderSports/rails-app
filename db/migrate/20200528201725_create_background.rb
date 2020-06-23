class CreateBackground < ActiveRecord::Migration[6.0]
  def change
    create_table :background, id: :uuid do |t|
      t.references :person, null: false, foreign_key: true, type: :uuid
      t.references :sport, foreign_key: true, type: :uuid
      t.column :category, :user_category
      t.integer :year
      t.boolean :primary, null: false, default: false
      t.jsonb :data, null: false, default: {}

      t.index [ :person_id, :primary ], unique: true, name: "unique_primary_background_index"
      t.index [ :person_id, :sport_id, :category, :year ], unique: true, name: "unique_background_index"
      t.index [ :data ], using: :gin

      t.timestamps default: -> { 'NOW()' }
    end
  end
end
