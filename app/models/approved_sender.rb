class ApprovedSender < ApplicationRecord
  belongs_to :trip
  belongs_to :approved_by, class_name: "User"

  validates :email, presence: true, uniqueness: { scope: :trip_id }
  validates :approved_at, presence: true
end
