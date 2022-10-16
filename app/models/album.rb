class Album < ApplicationRecord
  has_and_belongs_to_many :labels
  has_and_belongs_to_many :artists
  has_and_belongs_to_many :genres

  has_many :tracks, dependent: :destroy
  has_many :videos, dependent: :destroy

  validates :title, presence: true
end
