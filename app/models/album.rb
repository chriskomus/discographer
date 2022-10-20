##
# This class represents an album, or single piece of work from an artist. Such as an Album, EP, LP, Single, etc.
class Album < ApplicationRecord
  has_and_belongs_to_many :labels
  has_and_belongs_to_many :artists
  has_and_belongs_to_many :genres

  has_many :tracks, dependent: :destroy
  has_many :videos, dependent: :destroy
  has_many :releases, dependent: :destroy

  validates :title, presence: true

  def self.search(search)
    if search
      where(["title LIKE ?","%#{search}%"])
    else
      all
    end
  end
end
