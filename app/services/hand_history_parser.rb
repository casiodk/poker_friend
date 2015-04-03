class HandHistoryParser
	attr_reader :path, :hands_array

	def initialize(options={})
		@path 				= options.fetch(:path, "#{ Rails.root }/doc/sunday.txt")
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
	end

	def parse_hands
		hands_array.each do |hand_txt|
			# tournament
			tournament_id = (/Tournament #([\d]*?),/).match(hand_txt)[1]
			table_max 		= (/' ([\d]*?)-max/).match(hand_txt)[1]
			tournament 		= Tournament.where("uid = ?", tournament_id).first_or_create(uid: tournament_id, table_max: table_max.to_i)
			puts tournament.inspect

			# Table
			table_id 			= (/Table '([\d ]*?)'/).match(hand_txt)[1].remove(tournament_id).strip
			table 				= Table.where("tournament_id = ? AND uid = ?", tournament.id, table_id).first_or_create(tournament: tournament, uid: table_id)
			puts table.inspect

			# Hand
			hand_id 			= (/Hand #([\d]*?):/).match(hand_txt)[1]
			hand 					= Hand.joins(table: :tournament).where("hands.uid = ? AND tables.uid = ? AND tournaments.uid = ?", hand_id, table.uid, tournament.uid).first_or_create(uid: hand_id, table: table)
			puts hand.inspect

			# button
			button = (/Seat #([\d]*?) is the button/).match(hand_txt)[1]
			puts "button: #{ button }"

			(1..tournament.table_max).each do |num|
				seat_name = (/Seat #{ num }: (...*?) /).match(hand_txt).to_a[1]

				if seat_name.present?
					start_chips = (/Seat #{ num }: #{ seat_name.strip } \((...*?) in chips/).match(hand_txt).to_a[1]

					puts "start_chips #{ start_chips } "
				
					puts "seat #{ num }: #{ seat_name }" 
					player = Player.where("name = ?", seat_name).first_or_create(name: seat_name)
					ticket = Ticket.where("tournament_id = ? AND player_id = ?", tournament.id, player.id).first_or_create(tournament: tournament, player: player)

					puts player.inspect
					puts ticket.inspect
				end
				puts "tournament players count #{ tournament.players.count }"
			end
			
			puts "###################################################################################################"
		end
	end
end