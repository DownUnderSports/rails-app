class CreateAddress < ActiveRecord::Migration[6.0]
  def change
    create_table :address, id: :uuid do |t|
      t.references :country, null: false, type: :uuid
      t.citext :postal_code
      t.citext :region
      t.citext :city
      t.citext :delivery
      t.citext :backup
      t.text :verified_for, null: false, array: true, default: []
      t.text :rejected_for, null: false, array: true, default: []

      t.index [ :verified_for ], using: :gin
      t.index [ :rejected_for ], using: :gin

      t.timestamps default: -> { "NOW()" }
    end
  end
end
