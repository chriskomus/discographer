class AddDiscogsIdToReleases < ActiveRecord::Migration[7.0]
  def change
    add_column :releases, :discogs_id, :integer
  end
end
