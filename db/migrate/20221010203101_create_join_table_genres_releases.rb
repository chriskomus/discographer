class CreateJoinTableGenresReleases < ActiveRecord::Migration[7.0]
  def change
    create_join_table :genres, :releases do |t|
      # t.index [:genre_id, :release_id]
      # t.index [:release_id, :genre_id]
    end
  end
end
