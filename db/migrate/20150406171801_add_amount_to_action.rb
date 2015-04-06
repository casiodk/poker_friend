class AddAmountToAction < ActiveRecord::Migration
  def change
    add_column :actions, :amount, :integer
  end
end
