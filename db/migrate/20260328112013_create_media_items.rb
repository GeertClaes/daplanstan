class CreateMediaItems < ActiveRecord::Migration[8.1]
  def change
    create_table :media_items, id: :uuid do |t|
      t.references :trip, null: false, foreign_key: true, type: :uuid
      t.string :media_type, null: false
      t.string :caption
      t.datetime :taken_at
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.references :shortlist_item, foreign_key: true, type: :uuid
      t.references :accommodation, foreign_key: true, type: :uuid
      t.references :uploaded_by, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.timestamps
    end

    add_index :media_items, [ :trip_id, :taken_at ]
  end
end
