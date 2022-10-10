class CreateJoinTableArtistsLabels < ActiveRecord::Migration[7.0]
  def change
    create_join_table :artists, :labels do |t|
      # t.index [:artist_id, :label_id]
      # t.index [:label_id, :artist_id]
    end
  end
end
