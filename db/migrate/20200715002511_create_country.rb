class CreateCountry < ActiveRecord::Migration[6.0]
  def change
    create_table :country, id: :uuid do |t|
      t.citext :alpha_2, null: false
      t.citext :alpha_3, null: false
      t.text :numeric, null: false
      t.text :short,   null: false
      t.text :full,    null: false

      t.index [ :alpha_2 ], unique: true
      t.index [ :alpha_3 ], unique: true
      t.index [ :numeric ], unique: true
      t.index [ :short ], unique: true
      t.index [ :full ], unique: true
    end
  end
end
