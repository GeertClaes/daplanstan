class AddAccountIdToTrips < ActiveRecord::Migration[8.1]
  def change
    add_reference :trips, :account, null: false, foreign_key: true, type: :uuid
  end
end
