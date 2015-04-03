class Tournament < ActiveRecord::Base
	has_many :tickets, dependent: :destroy
	has_many :players, through: :tickets
end
