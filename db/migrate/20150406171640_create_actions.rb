class CreateActions < ActiveRecord::Migration
  def change
    create_table :actions do |t|
      t.belongs_to :placement, index: true
      t.belongs_to :round, index: true
      t.string :action
      t.string :action_txt
      t.integer :position

      t.timestamps null: false
    end
    add_foreign_key :actions, :placements
    add_foreign_key :actions, :rounds
  end
end
