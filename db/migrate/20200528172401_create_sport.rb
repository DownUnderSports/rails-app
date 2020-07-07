class CreateSport < ActiveRecord::Migration[6.0]
  def change
    create_table :sport, id: :uuid do |t|
      t.text :abbr, null: false
      t.text :full, null: false
      t.text :abbr_gendered, null: false
      t.text :full_gendered, null: false
      t.boolean :is_numbered, null: false, default: false
      t.jsonb :data, null: false, default: {}

      t.index [ :abbr_gendered ], unique: true
      t.index [ :full_gendered ], unique: true

      t.timestamps default: -> { 'NOW()' }
    end
  end
end
