class CreateTravelLegs < ActiveRecord::Migration[8.1]
  def change
    create_table :travel_legs, id: :uuid do |t|
      t.references :trip, null: false, foreign_key: true, type: :uuid
      t.string :mode, null: false
      t.string :departure_location, null: false
      t.datetime :departure_datetime, null: false
      t.string :arrival_location, null: false
      t.datetime :arrival_datetime, null: false
      t.string :carrier
      t.string :booking_reference
      t.text :notes
      t.references :added_by, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.string :source, default: "manual"
      t.references :inbox_item, foreign_key: true, type: :uuid
      t.timestamps
    end
  end
end
