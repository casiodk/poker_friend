class Deck	
	class << self
		def cards
			@cards ||= generate_cards
		end

		def shuffled_cards
			cards.shuffle
		end

	private
		def generate_cards
			card_array = []
			["s", "c", "d", "h"].each do |suite|
				["A", "2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K"].each do |val|
					card_array << Card.new(suite: suite, val: val)
				end
			end

			card_array
		end
	end
end