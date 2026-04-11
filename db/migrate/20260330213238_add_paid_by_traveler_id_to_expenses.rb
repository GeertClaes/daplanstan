class AddPaidByTravelerIdToExpenses < ActiveRecord::Migration[8.1]
  def change
    add_reference :expenses, :paid_by_traveler, null: true, foreign_key: { to_table: :travelers }, type: :uuid
  end
end
