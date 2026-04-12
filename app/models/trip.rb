class Trip < ApplicationRecord
  has_one_attached :cover_image

  belongs_to :account
  belongs_to :created_by, class_name: "User"
  has_many :trip_items, dependent: :destroy
  has_many :trip_members, dependent: :destroy
  has_many :travelers, through: :trip_members
  has_many :media_items, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :approved_senders, dependent: :destroy
  has_many :inbox_items, dependent: :destroy

  validates :title, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :inbound_email, presence: true, uniqueness: true

  before_validation :generate_inbound_email, on: :create, if: -> { inbound_email.blank? }

  def pending_review_count
    inbox_items.pending_review.count
  end

  def regenerate_inbound_email!
    update!(inbound_email: build_inbound_email)
  end

  private

  def generate_inbound_email
    self.inbound_email = build_inbound_email
  end

  def build_inbound_email
    "#{title.parameterize}-#{SecureRandom.hex(4)}@#{ENV.fetch("TRIP_EMAIL_DOMAIN", "whats.example.com")}"
  end
end
