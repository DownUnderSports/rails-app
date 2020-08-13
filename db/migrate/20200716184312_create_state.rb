class CreateState < ActiveRecord::Migration[6.0]
  def change
    create_table :state, { id: false } do |t|
      t.citext :abbr, null: false,
                      primary_key: true,
                      constraint: {
                                  value: "char_length(abbr) = 2",
                                  name: "state_abbr_length"
                                }

      t.citext :full, null: false
      t.jsonb :data, null: false, default: {}

      t.index [ :full ], unique: true

      t.timestamps default: -> { 'NOW()' }
    end
  end
end
