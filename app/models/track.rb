##
# This class represents a single track on an album
class Track < ApplicationRecord
  belongs_to :album

  validates :title, presence: true
end
