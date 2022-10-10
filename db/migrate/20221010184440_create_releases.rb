class CreateReleases < ActiveRecord::Migration[7.0]
  def change
    create_table :releases do |t|
      t.integer :year
      t.string :title
      t.string :country
      t.string :notes

      t.timestamps
    end
  end
end
