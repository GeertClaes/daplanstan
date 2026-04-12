class AddConfirmedToExpenses < ActiveRecord::Migration[8.1]
  def change
    add_column :expenses, :confirmed_at, :datetime
    add_column :expenses, :confirmed_by_id, :string
    add_column :expenses, :travel_leg_id, :string
  end
end
