##
# This class represents an album's release by a label.
# Each release will contain a reference to the album, label, and catalog number (catno)
class Release < ApplicationRecord
  belongs_to :label
  belongs_to :album

  def self.search(search)
    if search
      where(["catno LIKE ?","%#{search}%"])
    else
      all
    end
  end
end
