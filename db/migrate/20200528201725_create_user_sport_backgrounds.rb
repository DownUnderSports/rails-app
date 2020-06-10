class CreateUserSportBackgrounds < ActiveRecord::Migration[6.0]
  def change
    create_table :user_sport_backgrounds, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :sport, null: false, foreign_key: true, type: :uuid
      t.jsonb :data, null: false, default: {}

      t.timestamps default: -> { 'NOW()' }
    end
  end
end
