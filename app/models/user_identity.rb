class UserIdentity < ApplicationRecord
  belongs_to :user

  encrypts :access_token

  validates :provider, presence: true
  validates :provider_uid, presence: true
end
