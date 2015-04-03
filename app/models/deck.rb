class Deck
	attr_reader :card_array
	
	def initialize
		@card_array = []
		["s", "c", "d", "h"].each do |suite|
			["A", "2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K"].each do |val|
				@card_array << Card.new(suite: suite, val: val)
			end
		end
	end

	def cards
		@card_array
	end
end