##
# This class represents an album's release by a label.
# Each release will contain a reference to the album, label, and catalog number (catno)
class Release < ApplicationRecord
  belongs_to :label
  belongs_to :album
end
