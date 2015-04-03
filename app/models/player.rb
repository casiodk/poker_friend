class Player < ActiveRecord::Base
	has_many :tickets, dependent: :destroy
	has_many :tournaments, through: :tickets
end
