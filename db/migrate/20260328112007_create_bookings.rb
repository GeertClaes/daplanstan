class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings, id: :uuid do |t|
      t.references :trip, null: false, foreign_key: true, type: :uuid
      t.string :booking_type, null: false
      t.string :provider, null: false
      t.datetime :datetime
      t.string :confirmation_reference
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
