class HandType
	attr_reader :card_array, :type_hash

	def initialize(card_array)
		@card_array = card_array
		@type_hash = Hash.new
	end

	def call
		if royal_straight_flush?

		elsif straight_flush?

		elsif quads?

		elsif full_house?

		elsif flush?
			@type_hash[:type] = "flush"
			@type_hash[:array] = flush
		elsif straight?

		elsif trips?

		elsif two_pair?

		elsif pair?

		else
			@type_hash[:type] = "high_card"
			@type_hash[:array] = high_card
		end

		type_hash
	end

private

	def royal_straight_flush?
		false
	end

	def straight_flush?
		false
	end

	def quads?
		false
	end

	def full_house?
		false
	end

	# FLUSH
	def flush?
		flush.any?
	end

	def flush
		flush_array = []
		card_array.map.group_by { |c| c.to_s[1] }.each do |group|
			flush_array += group[1] if group[1].count >= 5
		end

		flush_array
	end

	def straight?
		false
	end

	def trips?
		false
	end

	def two_pair?
		false
	end

	def pair?
		false
	end

	def high_card
		card_array.sample(5)
	end
end