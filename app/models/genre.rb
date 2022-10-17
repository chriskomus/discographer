##
# This class represents a genre.
class Genre < ApplicationRecord
  has_and_belongs_to_many :albums

  validates :name, presence: true
end
