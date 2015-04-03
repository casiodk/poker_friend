class AddButtonToHand < ActiveRecord::Migration
  def change
    add_column :hands, :button, :integer
  end
end
