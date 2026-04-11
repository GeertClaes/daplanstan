class User < ApplicationRecord
  THEMES = %w[
    stan midnight dusk graphite sand
    andromeda ayudark catppuccin everforest flexoki
    githubdark githublight gruvbox kanagawa monokai
    nightfox nightowl onedarkpro rosepine solarized
    tokyonight vscode
  ].freeze

  validates :theme, inclusion: { in: THEMES }, allow_blank: true
  has_many :user_identities, dependent: :destroy
  has_one  :account, foreign_key: :owner_id, dependent: :destroy
  has_many :traveler_profiles, class_name: "Traveler", dependent: :nullify
  has_many :trip_members, through: :traveler_profiles
  has_many :trips, through: :trip_members
  has_many :created_trips,   class_name: "Trip",   foreign_key: :created_by_id, dependent: :destroy
  has_many :created_invites, class_name: "Invite", foreign_key: :created_by_id, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  def avatar(size: 80)
    avatar_url.presence || gravatar_url(size)
  end

  private

  def gravatar_url(size)
    hash = Digest::MD5.hexdigest(email.strip.downcase)
    "https://www.gravatar.com/avatar/#{hash}?s=#{size}&d=identicon"
  end
end
