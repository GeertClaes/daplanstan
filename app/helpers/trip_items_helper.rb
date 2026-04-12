module TripItemsHelper
  # ── Primary row (6 tiles) ────────────────────────────────────────────────────
  # "move" is a UI-only grouping — never stored as a kind value.
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

  # ── Transport sub-row (5 tiles, shown when Move is selected) ─────────────────
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

  # ── Full kind → SVG (for show views, map pins, etc.) ────────────────────────
  KIND_SVG = {
    "stay"   => "Stay.svg",
    "eat"    => "Eat.svg",
    "do"     => "Do.svg",
    "shop"   => "Shop.svg",
    "flight" => "Plane.svg",
    "car"    => "Car.svg",
    "train"  => "Train.svg",
    "ferry"  => "Ferry.svg",
    "other"  => "Expense.svg"
  }.freeze

  KIND_LABELS = {
    "stay"   => "Stay",
    "eat"    => "Eat",
    "do"     => "Do",
    "shop"   => "Shop",
    "flight" => "Flight",
    "car"    => "Car",
    "train"  => "Train",
    "ferry"  => "Ferry",
    "other"  => "Other"
  }.freeze

  KIND_COLOR = {
    "stay"   => "teal",
    "eat"    => "red",
    "do"     => "green",
    "shop"   => "pink",
    "flight" => "blue",
    "car"    => "amber",
    "train"  => "blue",
    "ferry"  => "blue",
    "other"  => "slate"
  }.freeze

  KIND_HEX = {
    "stay"   => "#0d9488",
    "eat"    => "#dc2626",
    "do"     => "#16a34a",
    "shop"   => "#db2777",
    "flight" => "#1d4ed8",
    "car"    => "#d97706",
    "train"  => "#1d4ed8",
    "ferry"  => "#1d4ed8",
    "other"  => "#6b7280"
  }.freeze

  def trip_item_kind_icon(kind, css_class: "h-5 w-5")
    file = KIND_SVG[kind.to_s] || "Map.svg"
    inline_svg(file, css_class: css_class)
  end

  def trip_item_kind_label(kind)
    KIND_LABELS[kind.to_s] || kind.to_s.humanize
  end

  # Returns the primary picker key for a given stored kind.
  # Transport kinds all map to "move" in the primary row.
  def trip_item_primary_key(kind)
    TripItem::TRANSPORT_KINDS.include?(kind.to_s) ? "move" : kind.to_s
  end
end
