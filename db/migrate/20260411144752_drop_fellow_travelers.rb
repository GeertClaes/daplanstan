class DropFellowTravelers < ActiveRecord::Migration[8.1]
  def up
    drop_table :fellow_travelers
  end

  def down
    create_table :fellow_travelers, id: :uuid do |t|
      t.references :owner,    null: false, foreign_key: { to_table: :users }, type: :uuid
      t.references :traveler,             foreign_key: { to_table: :users }, type: :uuid
      t.string :invited_email
      t.timestamps
    end
    add_index :fellow_travelers, %i[owner_id traveler_id], unique: true
    add_index :fellow_travelers, %i[owner_id invited_email], unique: true
  end
end
