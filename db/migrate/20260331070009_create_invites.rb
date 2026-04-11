class CreateInvites < ActiveRecord::Migration[8.1]
  def change
    create_table :invites, id: :uuid do |t|
      t.string     :token,    null: false
      t.string     :email                    # optional — restricts to one address
      t.string     :note                     # e.g. "for Sarah"
      t.references :created_by, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.references :used_by,    null: true,  foreign_key: { to_table: :users }, type: :uuid
      t.datetime   :used_at
      t.datetime   :expires_at
      t.timestamps
    end

    add_index :invites, :token, unique: true
  end
end
