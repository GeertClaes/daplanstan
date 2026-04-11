class Invite < ApplicationRecord
  belongs_to :created_by, class_name: "User"
  belongs_to :used_by,    class_name: "User", optional: true

  validates :token, presence: true, uniqueness: true

  before_validation :generate_token, on: :create

  scope :pending,  -> { where(used_at: nil) }
  scope :used,     -> { where.not(used_at: nil) }

  def used?    = used_at.present?
  def expired? = expires_at.present? && expires_at < Time.current
  def usable?  = !used? && !expired?

  def email_matches?(address)
    email.blank? || email.casecmp?(address.to_s)
  end

  private

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(16)
  end
end
