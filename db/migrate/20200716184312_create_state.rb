class CreateState < ActiveRecord::Migration[6.0]
  def change
    create_table :state, { id: false } do |t|
      t.citext :abbr, null: false,
                      primary_key: true,
                      constraint: {
                                  value: "abbr ~* '^[A-Z0-9]{2}$'",
                                  name: "state_abbr_format"
                                }

      t.citext :name, null: false
      t.jsonb :data, null: false, default: {}

      t.index [ :name ], unique: true

      t.timestamps default: -> { "NOW()" }
    end
  end
end
