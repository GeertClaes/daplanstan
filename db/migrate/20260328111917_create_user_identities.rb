class CreateUserIdentities < ActiveRecord::Migration[8.1]
  def change
    create_table :user_identities, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :provider, null: false
      t.string :provider_uid, null: false
      t.string :provider_email
      t.string :access_token
      t.timestamps
    end

    add_index :user_identities, [ :provider, :provider_uid ], unique: true
  end
end
