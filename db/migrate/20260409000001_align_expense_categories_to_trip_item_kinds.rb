class AlignExpenseCategoriesToTripItemKinds < ActiveRecord::Migration[8.1]
  def up
    execute "UPDATE expenses SET category = 'stay'       WHERE category = 'accommodation'"
    execute "UPDATE expenses SET category = 'restaurant' WHERE category = 'food_drink'"
    execute "UPDATE expenses SET category = 'flight'     WHERE category = 'transport'"
    execute "UPDATE expenses SET category = 'activity'   WHERE category = 'activities'"
  end

  def down
    execute "UPDATE expenses SET category = 'accommodation' WHERE category = 'stay'"
    execute "UPDATE expenses SET category = 'food_drink'    WHERE category = 'restaurant'"
    execute "UPDATE expenses SET category = 'transport'     WHERE category IN ('flight', 'car', 'train', 'ferry')"
    execute "UPDATE expenses SET category = 'activities'    WHERE category = 'activity'"
  end
end
