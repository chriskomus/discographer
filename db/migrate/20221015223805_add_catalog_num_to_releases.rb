class AddCatalogNumToReleases < ActiveRecord::Migration[7.0]
  def change
    add_column :releases, :catalog_num, :string
  end
end
