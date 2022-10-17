##
# This class represents a single YouTube video that is associated with an album, usually one of the tracks off the album.
class Video < ApplicationRecord
  belongs_to :album

  validates :title, presence: true
  validates :uri, presence: true
end
