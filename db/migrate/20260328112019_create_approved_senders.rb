class CreateApprovedSenders < ActiveRecord::Migration[8.1]
  def change
    create_table :approved_senders, id: :uuid do |t|
      t.references :trip, null: false, foreign_key: true, type: :uuid
      t.string :email, null: false
      t.string :display_name
      t.references :approved_by, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.timestamp :approved_at, null: false
      t.timestamps
    end

    add_index :approved_senders, [ :trip_id, :email ], unique: true
  end
end
