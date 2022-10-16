class Label < ApplicationRecord
  has_and_belongs_to_many :releases
  has_and_belongs_to_many :artists

  validates :name, presence: true
  validates :discogs_id, presence: true
end
