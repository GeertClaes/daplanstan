class UpdateTripsRemoveStatusBudgetAddCoverImage < ActiveRecord::Migration[8.1]
  def change
    remove_column :trips, :status,          :string
    remove_column :trips, :budget_amount,   :decimal
    remove_column :trips, :budget_currency, :string
    add_column :trips, :cover_image_url, :string unless column_exists?(:trips, :cover_image_url)
  end
end
