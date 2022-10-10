class AddReleaseToVideos < ActiveRecord::Migration[7.0]
  def change
    add_reference :videos, :release, null: false, foreign_key: true
  end
end
