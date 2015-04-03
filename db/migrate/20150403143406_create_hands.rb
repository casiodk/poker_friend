class CreateHands < ActiveRecord::Migration
  def change
    create_table :hands do |t|
      t.string :uid
      t.belongs_to :table, index: true

      t.timestamps null: false
    end
    add_foreign_key :hands, :tables
  end
end
