class Artist < ApplicationRecord
  has_and_belongs_to_many :releases
  has_and_belongs_to_many :labels

  validates :name, presence: true
end
