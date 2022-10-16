class RenameReleasesToAlbums < ActiveRecord::Migration[7.0]
  def change
    rename_table :albums, :albums
  end
end
