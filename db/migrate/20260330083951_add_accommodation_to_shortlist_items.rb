class AddAccommodationToShortlistItems < ActiveRecord::Migration[8.1]
  def change
    add_reference :shortlist_items, :accommodation, null: true, foreign_key: true, type: :uuid
  end
end
