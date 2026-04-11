class FinalizeAccountRefactor < ActiveRecord::Migration[8.1]
  def change
    # Make traveler_id non-null on trip_members (now that data is populated)
    change_column_null :trip_members, :traveler_id, false

    # Make account_id non-null on trips
    change_column_null :trips, :account_id, false

    # Remove old user_id from trip_members (replaced by traveler_id)
    remove_foreign_key :trip_members, column: :user_id, if_exists: true
    remove_column :trip_members, :user_id, :uuid, if_exists: true
    remove_column :trip_members, :invited_by_id, :uuid, if_exists: true

    # Remove old paid_by_id from expenses (replaced by paid_by_traveler_id)
    remove_foreign_key :expenses, column: :paid_by_id, if_exists: true
    remove_column :expenses, :paid_by_id, :uuid, if_exists: true
  end
end
