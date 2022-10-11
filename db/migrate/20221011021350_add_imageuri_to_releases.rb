class AddImageuriToReleases < ActiveRecord::Migration[7.0]
  def change
    add_column :releases, :imageuri, :string
  end
end
