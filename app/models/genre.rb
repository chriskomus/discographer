class Genre < ApplicationRecord
  has_and_belongs_to_many :releases

  validates :name, presence: true
end
