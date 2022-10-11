class AddImageuriToLabels < ActiveRecord::Migration[7.0]
  def change
    add_column :labels, :imageuri, :string
  end
end
