class TripMember < ApplicationRecord
  belongs_to :trip
  belongs_to :traveler

  enum :role, { owner: "owner", planner: "planner", contributor: "contributor", viewer: "viewer" }
  validates :role, presence: true
end
