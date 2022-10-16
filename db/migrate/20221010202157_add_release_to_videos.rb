class AddReleaseToVideos < ActiveRecord::Migration[7.0]
  def change
    add_reference :videos, :album, null: false, foreign_key: true
  end
end
