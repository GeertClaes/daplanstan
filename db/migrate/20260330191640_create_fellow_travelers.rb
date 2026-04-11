class CreateFellowTravelers < ActiveRecord::Migration[8.1]
  def change
    create_table :fellow_travelers, id: :uuid do |t|
      t.references :owner,    null: false, foreign_key: { to_table: :users }, type: :uuid
      t.references :traveler, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.timestamps
    end

    add_index :fellow_travelers, [ :owner_id, :traveler_id ], unique: true
  end
end
