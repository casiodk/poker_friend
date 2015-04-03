class AddTableMaxToTournament < ActiveRecord::Migration
  def change
    add_column :tournaments, :table_max, :integer
  end
end
