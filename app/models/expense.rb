class Expense < ApplicationRecord
  belongs_to :trip
  belongs_to :paid_by, class_name: "Traveler", foreign_key: :paid_by_traveler_id
  belongs_to :added_by, class_name: "User"
  belongs_to :trip_item, optional: true
  belongs_to :inbox_item, optional: true
  belongs_to :confirmed_by, class_name: "User", optional: true

  has_one_attached :receipt

  enum :category, {
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
  enum :source, { manual: "manual", receipt_photo: "receipt_photo", booking: "booking" }

  validates :amount, presence: true
  validates :currency, presence: true
  validates :description, presence: true
  validates :category, presence: true
  validates :expense_date, presence: true

  def confirmed?
    confirmed_at.present?
  end
end
