class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts, id: :uuid do |t|
      t.references :owner, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.string :name, null: false
      t.string :subscription_status, default: "free", null: false
      t.timestamps
    end
  end
end
