class AddPositionToRound < ActiveRecord::Migration
  def change
    add_column :rounds, :position, :integer
    add_index :rounds, :position
  end
end
