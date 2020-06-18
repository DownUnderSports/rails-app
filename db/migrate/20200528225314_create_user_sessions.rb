class CreateUserSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :user_sessions, id: :uuid do |t|
      t.references :user, null: false, type: :uuid, foreign_key: { to_table: :people }
      t.text :browser_id, null: false
      t.text :token_digest, null: false
      t.text :user_agent
      t.text :ip_address

      t.index [ :browser_id, :user_id ], unique: true

      t.timestamps default: -> { 'NOW()' }
    end
  end
end
