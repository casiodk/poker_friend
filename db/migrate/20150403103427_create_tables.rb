class CreateTables < ActiveRecord::Migration
  def change
    create_table :tables do |t|
      t.string :uid
      t.belongs_to :tournament, index: true

      t.timestamps null: false
    end
    add_foreign_key :tables, :tournaments
  end
end
