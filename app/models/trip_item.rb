class TripItem < ApplicationRecord
  include Geocodable

  belongs_to :trip
  belongs_to :added_by, class_name: "User"
  belongs_to :inbox_item, optional: true
  has_one :expense

  enum :kind, {
    stay:    "stay",
    eat:     "eat",
    "do":    "do",
    shop:    "shop",
    flight:  "flight",
    car:     "car",
    train:   "train",
    ferry:   "ferry",
    other:   "other"
  }

  enum :status, {
    idea:      "idea",
    confirmed: "confirmed"
  }

  validates :name, presence: true
  validates :kind, presence: true

  TRANSPORT_KINDS = %w[flight car train ferry].freeze

  # Don't geocode transport items (car/flight/train/ferry) unless a real address is present.
  # Company names like "Sicily By Car" geocode to wrong locations (company HQ, not trip area).
  def geocode_from_address
    return if TRANSPORT_KINDS.include?(kind.to_s) && address.blank?
    super
  end

  def expense_category
    kind
  end

  def when_label
    return nil unless starts_at
    has_time = starts_at.hour != 0 || starts_at.min != 0
    if ends_at.present?
      if ends_at.to_date != starts_at.to_date
        "#{starts_at.strftime("%-d %b")} – #{ends_at.strftime("%-d %b %Y")}"
      else
        has_time ? "#{starts_at.strftime("%-d %b · %H:%M")} – #{ends_at.strftime("%H:%M")}" : starts_at.strftime("%-d %b %Y")
      end
    else
      has_time ? starts_at.strftime("%-d %b %Y · %H:%M") : starts_at.strftime("%-d %b %Y")
    end
  end
end
