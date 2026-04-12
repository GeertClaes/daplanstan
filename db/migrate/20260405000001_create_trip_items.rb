class CreateTripItems < ActiveRecord::Migration[8.1]
  def change
    create_table :trip_items, id: :uuid do |t|
      t.references :trip,       null: false, foreign_key: true,                    type: :uuid
      t.references :added_by,   null: false, foreign_key: { to_table: :users },   type: :uuid
      t.references :inbox_item, null: true,  foreign_key: true,                    type: :uuid

      t.string  :kind,             null: false
      t.string  :name,             null: false
      t.string  :status,           null: false, default: "idea"
      t.text    :notes
      t.datetime :starts_at
      t.datetime :ends_at
      t.string  :address
      t.decimal :latitude,         precision: 10, scale: 6
      t.decimal :longitude,        precision: 10, scale: 6
      t.decimal :amount,           precision: 10, scale: 2
      t.string  :currency
      t.string  :confirmation_ref

      t.timestamps
    end

    add_index :trip_items, [ :trip_id, :starts_at ]

    add_column :expenses, :trip_item_id, :uuid
    add_index  :expenses, :trip_item_id
    add_foreign_key :expenses, :trip_items
  end
end
