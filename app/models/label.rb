##
# This class represents a record label
class Label < ApplicationRecord
  has_and_belongs_to_many :albums
  has_and_belongs_to_many :artists

  has_many :releases

  validates :name, presence: true

  def self.search(search)
    if search
      where(["name LIKE ?","%#{search}%"])
    else
      all
    end
  end
end
