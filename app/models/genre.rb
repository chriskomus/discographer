##
# This class represents a genre.
class Genre < ApplicationRecord
  has_and_belongs_to_many :albums

  validates :name, presence: true

  def self.search(search)
    if search
      where(["name LIKE ?","%#{search}%"])
    else
      all
    end
  end
end
