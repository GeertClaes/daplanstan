class CreateAccommodations < ActiveRecord::Migration[8.1]
  def change
    create_table :accommodations, id: :uuid do |t|
      t.references :trip, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.string :address
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.datetime :check_in, null: false
      t.datetime :check_out, null: false
      t.string :confirmation_number
      t.text :notes
      t.decimal :cost, precision: 10, scale: 2
      t.string :currency
      t.references :added_by, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.string :source, default: "manual"
      t.references :inbox_item, foreign_key: true, type: :uuid
      t.timestamps
    end
  end
end
