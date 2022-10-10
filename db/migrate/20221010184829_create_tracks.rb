class CreateTracks < ActiveRecord::Migration[7.0]
  def change
    create_table :tracks do |t|
      t.integer :position
      t.string :title
      t.string :duration

      t.timestamps
    end
  end
end
