class AddThemeToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :theme, :string, default: "midnight", null: false
  end
end
