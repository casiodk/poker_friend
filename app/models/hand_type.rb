class HandType # HandValues
	attr_reader :card_array, :type_hash

	def initialize(card_array) # community cards, glove, board, 
		@card_array = card_array
		@type_hash = Hash.new
	end

	def call
		if royal_straight_flush?

		elsif straight_flush?

		elsif quads?
			@type_hash[:type] = "quads"
			@type_hash[:array] = quads_array
		elsif full_house?
			@type_hash[:type] = "full_house"
			@type_hash[:array] = [*trips_array, *pair_array]
		elsif flush?
			@type_hash[:type] = "flush"
			@type_hash[:array] = flush
		elsif straight?

		elsif trips?
			@type_hash[:type] = "trips"
			@type_hash[:array] = trips_array
		elsif two_pair?
			@type_hash[:type] = "two_pair"
			@type_hash[:array] = pair_array
		elsif one_pair?
			@type_hash[:type] = "one_pair"
			@type_hash[:array] = pair_array
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
		quads_array.count == 1
	end

	def full_house?
		trips_array.count == 1 && pair_array.count >= 2
	end

	# FLUSH
	def flush?
		flush.any?
	end

	def flush
		a = []
		suite_groups.each do |group|
			a += group[1] if group[1].count >= 5
		end

		a
	end

	def straight?(c_array=card_array)
		false
	end

	def trips?
		trips_array.count >= 1
	end

	def two_pair?
		pair_array.count >= 2
	end

	def one_pair?
		pair_array.count == 1
	end

	def high_card
		card_array.sample(5)
	end

	def pair_array
		@pair_array ||= generate_match_array(2)
	end

	def trips_array
		@trips_array ||= generate_match_array(3)
	end

	def quads_array
		@quads_array ||= generate_match_array(4)
	end

	def generate_match_array(num)
		a = []
		value_groups.each do |group|
			a += [group[1]] if group[1].count == num
		end
		
		a
	end

	def value_groups
		@value_groups ||= generate_value_groups
	end

	def suite_groups
		@suite_groups ||= generate_suite_groups
	end

	def generate_value_groups(c_array=card_array)
		c_array.map.group_by(&:val)
	end

	def generate_suite_groups(c_array=card_array)
		c_array.map.group_by(&:suite)
	end
end