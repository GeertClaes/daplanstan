class AddUrlToTripItems < ActiveRecord::Migration[8.1]
  def change
    add_column :trip_items, :url, :string
  end
end
