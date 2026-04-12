class CreateTrips < ActiveRecord::Migration[8.1]
  def change
    create_table :trips, id: :uuid do |t|
      t.string :title, null: false
      t.text :description
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.string :cover_image_url
      t.string :status, default: "planning", null: false
      t.string :inbound_email, null: false
      t.decimal :budget_amount, precision: 10, scale: 2
      t.string :budget_currency, default: "EUR"
      t.references :created_by, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.timestamps
    end

    add_index :trips, :inbound_email, unique: true
  end
end
