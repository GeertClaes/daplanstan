class RenameKindsToUserTerms < ActiveRecord::Migration[8.1]
  def up
    execute "UPDATE trip_items SET kind = 'eat'  WHERE kind = 'restaurant'"
    execute "UPDATE trip_items SET kind = 'do'   WHERE kind = 'activity'"
    execute "UPDATE trip_items SET kind = 'shop' WHERE kind = 'shopping'"
    execute "UPDATE expenses SET category = 'eat'  WHERE category = 'restaurant'"
    execute "UPDATE expenses SET category = 'do'   WHERE category = 'activity'"
    execute "UPDATE expenses SET category = 'shop' WHERE category = 'shopping'"
  end

  def down
    execute "UPDATE trip_items SET kind = 'restaurant' WHERE kind = 'eat'"
    execute "UPDATE trip_items SET kind = 'activity'   WHERE kind = 'do'"
    execute "UPDATE trip_items SET kind = 'shopping'   WHERE kind = 'shop'"
    execute "UPDATE expenses SET category = 'restaurant' WHERE category = 'eat'"
    execute "UPDATE expenses SET category = 'activity'   WHERE category = 'do'"
    execute "UPDATE expenses SET category = 'shopping'   WHERE category = 'shop'"
  end
end
