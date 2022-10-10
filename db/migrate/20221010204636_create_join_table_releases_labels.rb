class CreateJoinTableReleasesLabels < ActiveRecord::Migration[7.0]
  def change
    create_join_table :releases, :labels do |t|
      # t.index [:release_id, :label_id]
      # t.index [:label_id, :release_id]
    end
  end
end
