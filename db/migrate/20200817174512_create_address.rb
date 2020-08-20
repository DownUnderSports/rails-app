class CreateAddress < ActiveRecord::Migration[6.0]
  def change
    create_table :address, id: :uuid do |t|
      t.references :country, null: false, type: :uuid
      t.citext :postal_code
      t.citext :region
      t.citext :city
      t.citext :delivery
      t.citext :backup
      t.boolean :verified, null: false, default: false
      t.boolean :rejected, null: false, default: false

      t.index [ :verified ]
      t.index [ :rejected ]

      t.timestamps default: -> { 'NOW()' }
    end
  end
end
