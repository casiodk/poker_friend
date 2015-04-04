class AddIndexForUids < ActiveRecord::Migration
  def change
  	add_index :hands, :uid
  	add_index :tables, :uid
  	add_index :tournaments, :uid
  end
end
