##
# This class represents a single track on an album
class Track < ApplicationRecord
  belongs_to :album

  validates :title, presence: true

  def self.search(search)
    if search
      where(["title LIKE ?","%#{search}%"])
    else
      all
    end
  end
end
