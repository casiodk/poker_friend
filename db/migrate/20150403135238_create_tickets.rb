class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.belongs_to :player, index: true
      t.belongs_to :tournament, index: true

      t.timestamps null: false
    end
    add_foreign_key :tickets, :players
    add_foreign_key :tickets, :tournaments
  end
end
