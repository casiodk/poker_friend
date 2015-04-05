class Player < ActiveRecord::Base
	has_many :tickets, dependent: :destroy
	has_many :tournaments, through: :tickets
	has_many :placements, dependent: :destroy
end
