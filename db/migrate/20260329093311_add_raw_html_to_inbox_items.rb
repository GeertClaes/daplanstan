class AddRawHtmlToInboxItems < ActiveRecord::Migration[8.1]
  def change
    add_column :inbox_items, :raw_html, :text
  end
end
