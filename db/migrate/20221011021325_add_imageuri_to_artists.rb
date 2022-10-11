class AddImageuriToArtists < ActiveRecord::Migration[7.0]
  def change
    add_column :artists, :imageuri, :string
  end
end
