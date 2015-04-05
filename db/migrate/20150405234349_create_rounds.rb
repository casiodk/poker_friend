class CreateRounds < ActiveRecord::Migration
  def change
    create_table :rounds do |t|
      t.belongs_to :hand, index: true
      t.string :stage

      t.timestamps null: false
    end
    add_foreign_key :rounds, :hands
  end
end
