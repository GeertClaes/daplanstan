class MediaItem < ApplicationRecord
  belongs_to :trip
  belongs_to :uploaded_by, class_name: "User"
  has_one_attached :file

  validates :media_type, presence: true
end
