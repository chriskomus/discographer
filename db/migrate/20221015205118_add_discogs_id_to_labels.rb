class AddDiscogsIdToLabels < ActiveRecord::Migration[7.0]
  def change
    add_column :labels, :discogs_id, :integer
  end
end
