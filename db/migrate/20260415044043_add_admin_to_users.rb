class AddAdminToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :admin, :boolean, default: false, null: false
    User.find_by(email: "geert.wl.claes@gmail.com")&.update_columns(admin: true)
  end
end
