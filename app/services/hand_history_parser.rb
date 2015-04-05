class HandHistoryParser
	attr_reader :path, :hands_array

	# hand parser
	attr_reader :hand_txt, :tournament, :table, :hand, :table_max, :button, :hero_name, :hero_glove

	# seat parser
	attr_reader :num, :seat_name, :escaped_seat_name, :player, :ticket, :start_chips, :placement, :player_glove

	def initialize(options={})
		# for testing
		system "rake db:reset"
		Tournament.destroy_all
		Table.destroy_all
		Player.destroy_all
		Hand.destroy_all
		Placement.destroy_all
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

	def reset_parse_hand
		@hand_txt 		= nil
		@table_max 		= nil
		@button 			= nil
		@hero_name 		= nil
		@hero_glove 	= nil
		@tournament 	= nil
		@table 				= nil
		@hand 				= nil
	end

	def set_parse_hand_variables(hand_txt)
		set_hand_txt(hand_txt)
		set_table_max
		set_button
		set_hero_name
		set_hero_glove
		set_tournament
		set_table
		set_hand
	end

	def set_hand_txt(hand_txt)
		@hand_txt = hand_txt

		runtime_error("hand_txt not present") unless hand_txt.present?
	end

	def set_table_max
		@table_max = (/' ([\d]*?)-max/).match(hand_txt)[1]

		runtime_error("table_max not present") unless table_max.present?
	end

	def set_button
		@button = (/Seat #([\d]*?) is the button/).match(hand_txt)[1]

		runtime_error("button not present") unless button.present?
	end

	def set_hero_name
		@hero_name = (/Dealt to (...*?) /).match(hand_txt)[1]
	end

	def set_hero_glove
		@hero_glove = (/Dealt to #{ hero_name } \[(...*?)\]/).match(hand_txt)[1]
	end

	def set_tournament
		tournament_id = (/Tournament #([\d]*?),/).match(hand_txt)[1]
		@tournament 	= Tournament.where("uid = ?", tournament_id).first_or_create(uid: tournament_id, table_max: table_max.to_i)
		
		runtime_error("Could not find_or_create tournament with tournament_id: #{ tournament_id }") unless tournament
	end

	def set_table
		table_id 			= (/Table '([\d ]*?)'/).match(hand_txt)[1].remove(tournament.uid).strip
		@table 				= Table.where("tournament_id = ? AND uid = ?", tournament.id, table_id).first_or_create(tournament: tournament, uid: table_id)
		
		runtime_error("Could not find_or_create table with table_id: #{ table_id }") unless table
	end

	def set_hand
		hand_id 			= (/Hand #([\d]*?):/).match(hand_txt)[1]
		
		existing_hand = Hand.joins(table: :tournament).where("hands.uid = ? AND tables.id = ? AND tournaments.id = ?", hand_id, table.id, tournament.id).first
		runtime_error("Hand ##{ existing_hand.id } uid: #{ existing_hand.uid } already processed") if existing_hand

		@hand 				= Hand.create(uid: hand_id, table: table, button: button)
		runtime_error("Could not find_or_create hand with hand_id: #{ hand_id }") unless @hand
	end

	# PARSE SEAT
	def reset_parse_seat
		@num 								= nil
		@seat_name 					= nil
		@escaped_seat_name 	= nil
		@player 						= nil
		@ticket 						= nil
		@start_chips 				= nil
		@placement 					= nil
		@player_glove 			= nil
	end

	def set_parse_seat_variables(num)
		set_num(num)
		set_seat_name
		set_escaped_seat_name
		set_player
		set_ticket
		set_start_chips
		set_placement
		set_player_glove
	end

	def set_num(num)
		@num = num

		runtime_error("num not present") unless num.present?
	end

	def set_seat_name
		@seat_name = (/Seat #{ num }: (...*?) /).match(hand_txt).to_a[1]

		runtime_error("seat_name could not be found with num #{ num }") unless seat_name.present?
	end

	def set_escaped_seat_name
		@escaped_seat_name = seat_name.strip.gsub(".", "\\.").gsub("^", "\\^").gsub("$", "\\$").gsub("*", "\\*").gsub("+", "\\+").gsub("?", "\\?").gsub("(", "\\(").gsub(")", "\\)").gsub("[", "\\[").gsub("{", "\\{").gsub("|", "\\|")
	end

	def set_player
		@player = Player.where("name = ?", seat_name).first_or_create!(name: seat_name)

		runtime_error("Could not find_or_create player with seat_name: #{ seat_name }") unless player
	end

	def set_ticket
		@ticket = Ticket.where("tournament_id = ? AND player_id = ?", tournament.id, player.id).first_or_create!(tournament: tournament, player: player)

		runtime_error("Could not find_or_create ticket with tournament_id: #{ tournament.id } AND player_id: #{ player.id }") unless ticket
	end

	def set_start_chips
		@start_chips = (/Seat #{ num }: #{ escaped_seat_name.strip } \((...*?) in chips/).match(hand_txt).to_a[1]

		runtime_error("Could not set start_chips for seat_name: #{ escaped_seat_name } AND num #{ num }") unless start_chips.present?
	end

	def set_placement
		@placement 	= Placement.where("player_id = ? AND hand_id = ?", player.id, hand.id).first_or_create!(player: player, hand: hand, start_chips: start_chips, seat: num)

		runtime_error("Could not find_or_create placement with player.id: #{ player.id } AND hand.id: #{ hand.id }") unless placement
	end

	def set_player_glove
		@player_glove = (/#{ escaped_seat_name }: shows \[(...*?)\]/).match(hand_txt).to_a[1]
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

	def parse_hand(hand_txt)
		begin
			reset_parse_hand
			set_parse_hand_variables(hand_txt)

			(1..tournament.table_max).each do |num|
				parse_seat(num)
			end

		rescue RuntimeError => error
			puts error
		end

		parse_preflop_actions
		parse_flop_actions
		parse_turn_actions
		parse_river_actions
	end

	def parse_seat(num)
		begin
			reset_parse_seat
			set_parse_seat_variables(num)
			create_player_glove
		rescue RuntimeError => error
			puts error
		end
	end

	def create_player_glove
		if player_glove.present?
			Card.create!(val: player_glove[0], suite: player_glove[1], placement: placement)
			Card.create!(val: player_glove[3], suite: player_glove[4], placement: placement)
		end

		if seat_name == hero_name && placement.cards.empty?
			Card.create!(val: hero_glove[0], suite: hero_glove[1], placement: placement)
			Card.create!(val: hero_glove[3], suite: hero_glove[4], placement: placement)
		end
	end

	def parse_preflop_actions
		if (/\*\*\* FLOP \*\*\*(...*?)$/).match(hand_txt).to_a[1].present?
			preflop_text = (/\*\*\* HOLE CARDS \*\*\*(...*?)\*\*\* FLOP \*\*\*/m).match(hand_txt).to_a[1]
		else
			preflop_text = (/\*\*\* HOLE CARDS \*\*\*(...*?)\*\*\* SUMMARY \*\*\*/m).match(hand_txt).to_a[1]
		end

		action_txts = "#{ preflop_text }".scan(/^.*:.*$/)

		puts "€€€€€€€€€€€€€€€€"
		
		action_txts.each do |action_txt|
			puts "--------------------"
			puts action_txt
			
			player 						= (/^(...*?):/).match(action_txt).to_a[1]
			whole_action_txt 	= (/:(...*?)$/).match(action_txt).to_a[1].to_s.strip
			action 						= (/(?:^|(?:[.!?]\s))(\w+)/).match(whole_action_txt).to_a[1]
			amount 						= (/^[^\d]*(\d+)/).match(whole_action_txt).to_a[1]
			
			puts "player: #{ player }"
			puts "whole_action:#{ whole_action_txt }"
			puts "action #{ action }"
			puts "amount #{ amount }"
		end

		puts "€€€€€€€€€€€€€€€€"
	end

	def parse_flop_actions

	end

	def parse_turn_actions

	end

	def parse_river_actions

	end
end


