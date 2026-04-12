module ExpensesHelper
  # Full category → SVG (for show views, list icons, etc.)
  CATEGORY_SVG = {
    "stay"    => "Stay.svg",
    "eat"     => "Eat.svg",
    "flight"  => "Plane.svg",
    "car"     => "Car.svg",
    "train"   => "Train.svg",
    "ferry"   => "Ferry.svg",
    "do"      => "Do.svg",
    "shop"    => "Shop.svg",
    "other"   => "Expense.svg"
  }.freeze

  CATEGORY_LABELS = {
    "stay"    => "Stay",
    "eat"     => "Eat",
    "flight"  => "Flight",
    "car"     => "Car",
    "train"   => "Train",
    "ferry"   => "Ferry",
    "do"      => "Do",
    "shop"    => "Shop",
    "other"   => "Other"
  }.freeze

  # Primary row (6 tiles) — "move" groups all transport kinds
  PRIMARY_SVG = {
    "stay"  => "Stay.svg",
    "eat"   => "Eat.svg",
    "move"  => "Move.svg",
    "do"    => "Do.svg",
    "shop"  => "Shop.svg",
    "other" => "Expense.svg"
  }.freeze

  PRIMARY_LABELS = {
    "stay"  => "Stay",
    "eat"   => "Eat",
    "move"  => "Move",
    "do"    => "Do",
    "shop"  => "Shop",
    "other" => "Other"
  }.freeze

  # Transport sub-row (5 tiles, shown when Move is selected)
  TRANSPORT_SVG = {
    "flight" => "Plane.svg",
    "car"    => "Car.svg",
    "train"  => "Train.svg",
    "ferry"  => "Ferry.svg",
    "other"  => "Bus-Taxi.svg"
  }.freeze

  TRANSPORT_LABELS = {
    "flight" => "Plane",
    "car"    => "Car",
    "train"  => "Train",
    "ferry"  => "Ferry",
    "other"  => "Other"
  }.freeze

  TRANSPORT_KINDS = %w[flight car train ferry].freeze

  COMMON_CURRENCIES = %w[EUR GBP USD CHF AUD CAD JPY SEK NOK DKK PLN CZK HUF].freeze

  def expense_category_icon(category, css_class: "h-5 w-5")
    file = CATEGORY_SVG[category.to_s] || "Expense.svg"
    inline_svg(file, css_class: css_class)
  end

  def expense_category_label(category)
    CATEGORY_LABELS[category.to_s] || category.to_s.humanize
  end

  # Returns the primary picker key for a given stored category.
  # Transport kinds all map to "move" in the primary row.
  def expense_primary_key(category)
    TRANSPORT_KINDS.include?(category.to_s) ? "move" : category.to_s
  end
end
