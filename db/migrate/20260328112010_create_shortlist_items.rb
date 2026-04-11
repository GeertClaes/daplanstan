class CreateShortlistItems < ActiveRecord::Migration[8.1]
  def change
    create_table :shortlist_items, id: :uuid do |t|
      t.references :trip, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.string :category, null: false
      t.string :address
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.text :notes
      t.string :source_url
      t.string :google_place_id
      t.string :status, default: "shortlisted"
      t.date :planned_date
      t.references :added_by, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.string :source, default: "manual"
      t.references :inbox_item, foreign_key: true, type: :uuid
      t.timestamps
    end

    add_index :shortlist_items, [ :trip_id, :status ]
  end
end
