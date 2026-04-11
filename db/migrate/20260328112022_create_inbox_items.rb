class CreateInboxItems < ActiveRecord::Migration[8.1]
  def change
    create_table :inbox_items, id: :uuid do |t|
      t.references :trip, null: false, foreign_key: true, type: :uuid
      t.string :from_email, null: false
      t.string :from_name
      t.string :subject
      t.text :raw_body
      t.text :attachments_json
      t.datetime :received_at, null: false
      t.string :sender_status, default: "pending_approval"
      t.string :parse_status, default: "unparsed"
      t.string :parsed_type
      t.text :parsed_data_json
      t.string :review_status, default: "pending_review"
      t.references :reviewed_by, foreign_key: { to_table: :users }, type: :uuid
      t.datetime :reviewed_at
      t.timestamps
    end

    add_index :inbox_items, [ :trip_id, :sender_status, :review_status ]
  end
end
