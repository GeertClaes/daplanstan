class RemoveLegacyTravelModels < ActiveRecord::Migration[8.1]
  def up
    # Remove legacy foreign key columns from expenses
    remove_column :expenses, :accommodation_id
    remove_column :expenses, :travel_leg_id
    remove_column :expenses, :booking_id

    # Remove legacy foreign key columns from media_items
    remove_column :media_items, :accommodation_id
    remove_column :media_items, :shortlist_item_id

    # Drop legacy tables (dependents first)
    drop_table :shortlist_items
    drop_table :bookings
    drop_table :accommodations
    drop_table :travel_legs
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
