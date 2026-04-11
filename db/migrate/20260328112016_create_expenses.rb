class CreateExpenses < ActiveRecord::Migration[8.1]
  def change
    create_table :expenses, id: :uuid do |t|
      t.references :trip, null: false, foreign_key: true, type: :uuid
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :currency, null: false, default: "EUR"
      t.string :description, null: false
      t.string :category, null: false
      t.date :expense_date, null: false
      t.references :paid_by, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.references :booking, foreign_key: true, type: :uuid
      t.references :accommodation, foreign_key: true, type: :uuid
      t.references :added_by, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.string :source, default: "manual"
      t.timestamps
    end
  end
end
