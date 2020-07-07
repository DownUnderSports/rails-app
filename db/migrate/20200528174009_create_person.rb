class CreatePerson < ActiveRecord::Migration[6.0]
  def change
    create_table :person, id: :uuid do |t|
      t.column :category, :user_category, null: false
      t.text :title
      t.text :first_names, null: false
      t.text :middle_names
      t.text :last_names, null: false
      t.text :suffix
      t.column :email, :citext
      t.text :password_digest
      t.text :single_use_digest
      t.datetime :single_use_expires_at
      t.jsonb :data, null: false, default: {}

      t.index [ :category ]
      t.index [ :email ], unique: true
      t.index [ :data ], using: :gin

      t.timestamps default: -> { 'NOW()' }
    end


  end
end
