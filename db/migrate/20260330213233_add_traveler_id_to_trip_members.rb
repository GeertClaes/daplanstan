class AddTravelerIdToTripMembers < ActiveRecord::Migration[8.1]
  def change
    add_reference :trip_members, :traveler, null: true, foreign_key: true, type: :uuid
    remove_index :trip_members, %i[trip_id user_id], if_exists: true
    add_index :trip_members, %i[trip_id traveler_id], unique: true, if_not_exists: true
  end
end
