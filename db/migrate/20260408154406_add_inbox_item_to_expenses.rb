class AddInboxItemToExpenses < ActiveRecord::Migration[8.1]
  def change
    add_reference :expenses, :inbox_item, null: true, foreign_key: true, type: :uuid
  end
end
