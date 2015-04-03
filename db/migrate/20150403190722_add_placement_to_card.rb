class AddPlacementToCard < ActiveRecord::Migration
  def change
    add_reference :cards, :placement, index: true
    add_foreign_key :cards, :placements
  end
end
