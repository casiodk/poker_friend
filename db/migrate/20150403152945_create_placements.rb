class CreatePlacements < ActiveRecord::Migration
  def change
    create_table :placements do |t|
      t.belongs_to :player, index: true
      t.belongs_to :hand, index: true
      t.integer :seat
      t.integer :start_chips

      t.timestamps null: false
    end
    add_foreign_key :placements, :players
    add_foreign_key :placements, :hands
  end
end
