class CreateSport < ActiveRecord::Migration[6.0]
  def change
    create_table :sport, id: :uuid do |t|
      t.text :abbr
      t.text :full
      t.text :abbr_gendered
      t.text :full_gendered
      t.boolean :is_numbered, null: false, default: false
      t.jsonb :data, null: false, default: {}

      t.timestamps default: -> { 'NOW()' }
    end
  end
end
