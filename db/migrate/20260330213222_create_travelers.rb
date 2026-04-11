class CreateTravelers < ActiveRecord::Migration[8.1]
  def change
    create_table :travelers, id: :uuid do |t|
      t.references :account, null: false, foreign_key: true, type: :uuid
      t.references :user, null: true, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.string :email
      t.string :avatar_url
      t.datetime :invite_accepted_at
      t.timestamps
    end
    add_index :travelers, %i[account_id user_id], unique: true, where: "user_id IS NOT NULL"
  end
end
