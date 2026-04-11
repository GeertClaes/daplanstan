class Traveler < ApplicationRecord
  belongs_to :account
  belongs_to :user, optional: true
  has_many :trip_members, dependent: :destroy
  has_many :trips, through: :trip_members

  validates :name, presence: true
  validates :user_id, uniqueness: { scope: :account_id, message: "is already in this account" }, allow_nil: true

  def avatar(size: 80)
    avatar_url.presence || user&.avatar_url.presence || gravatar_url(size)
  end

  def display_email
    email.presence || user&.email
  end

  def pending?
    user_id.nil? && email.present?
  end

  def managed?
    user_id.nil? && email.blank?
  end

  def accept!(user)
    update!(user: user, name: name.presence || user.name, invite_accepted_at: Time.current)
  end

  private

  def gravatar_url(size)
    e = display_email
    return "https://www.gravatar.com/avatar/unknown?s=#{size}&d=identicon" unless e
    hash = Digest::MD5.hexdigest(e.strip.downcase)
    "https://www.gravatar.com/avatar/#{hash}?s=#{size}&d=identicon"
  end
end
