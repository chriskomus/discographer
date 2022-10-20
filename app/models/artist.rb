##
# This class represents a musical artist
class Artist < ApplicationRecord
  has_and_belongs_to_many :albums
  has_and_belongs_to_many :labels

  validates :name, presence: true

  def self.search(search)
    if search
      where(["name LIKE ?","%#{search}%"])
    else
      all
    end
  end
end
