class CreateTripMembers < ActiveRecord::Migration[8.1]
  def change
    create_table :trip_members, id: :uuid do |t|
      t.references :trip, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :role, null: false, default: "viewer"
      t.references :invited_by, foreign_key: { to_table: :users }, type: :uuid
      t.timestamp :joined_at
      t.timestamps
    end

    add_index :trip_members, [ :trip_id, :user_id ], unique: true
  end
end
