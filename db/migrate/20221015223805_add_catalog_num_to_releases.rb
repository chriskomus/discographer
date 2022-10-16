class AddCatalogNumToReleases < ActiveRecord::Migration[7.0]
  def change
    add_column :albums, :catalog_num, :string
  end
end
