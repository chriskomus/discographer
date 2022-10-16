class AddImageuriToReleases < ActiveRecord::Migration[7.0]
  def change
    add_column :albums, :imageuri, :string
  end
end
