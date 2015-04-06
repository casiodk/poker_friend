class HandHistoryParser
	include HandHistoryParserParseHand
	attr_reader :path, :hands_array
	
	

	def initialize(options={})
		# for testing
		system "rake db:reset"
		Tournament.destroy_all
		Table.destroy_all
		Player.destroy_all
		Hand.destroy_all
		Placement.destroy_all
		Round.destroy_all

		@path 				= options.fetch(:path, "#{ Rails.root }/doc/sunday_1.txt")
		@hands_array 	= []
	end

	def parse
		generate_hands_array
		parse_hands
	end

private
	def file
		@file ||= File.open(path, 'r')
	end

	def text
		@text ||= file.read
	end

	def generate_hands_array
		txt = nil
		file.each do |line|
			if line =~ /PokerStars Hand/i
				@hands_array << txt unless txt.nil?
				txt = ""
			end
			txt += line			
		end
		@hands_array << txt unless txt.nil?
	end

	# MISC
	def runtime_error(e)
		raise RuntimeError, "############################## #{ e }"
	end

	def parse_hands
		hands_array.each do |hand_txt|
			parse_hand(hand_txt)
		end
	end
end
