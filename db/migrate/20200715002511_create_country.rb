class CreateCountry < ActiveRecord::Migration[6.0]
  def change
    create_table :country, id: :uuid do |t|
      t.citext :alpha_2, null: false,
                         constraint: {
                           value: "alpha_2 ~* '^[A-Z]{2}$'",
                           name: "country_alpha_2_format"
                         }
      t.citext :alpha_3, null: false,
                         constraint: {
                           value: "alpha_3 ~* '^[A-Z]{3}$'",
                           name: "country_alpha_3_format"
                         }
      t.text :numeric, null: false,
                       constraint: {
                         value: "numeric ~* '^[0-9]{3}$'",
                         name: "country_numeric_format"
                       }
      t.text :short, null: false
      t.text :name, null: false

      t.index [ :alpha_2 ], unique: true
      t.index [ :alpha_3 ], unique: true
      t.index [ :numeric ], unique: true
      t.index [ :short ],   unique: true
      t.index [ :name ],    unique: true
    end
  end
end
