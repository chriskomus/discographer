class CreateJoinTableArtistsReleases < ActiveRecord::Migration[7.0]
  def change
    create_join_table :artists, :albums do |t|
      # t.index [:artist_id, :release_id]
      # t.index [:release_id, :artist_id]
    end
  end
end
