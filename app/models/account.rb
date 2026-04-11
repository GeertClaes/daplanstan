class Account < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many :travelers, dependent: :destroy
  has_many :trips, dependent: :destroy

  validates :name, presence: true
  validates :owner_id, uniqueness: { message: "already has an account" }

  def owner_traveler
    travelers.find_by(user: owner)
  end
end
