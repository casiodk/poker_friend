class HandHistoryParser
	attr_reader :path, :hands_array

	def initialize(options={})
		# for testing
		Tournament.destroy_all
		Table.destroy_all
		Player.destroy_all
		Hand.destroy_all
		Placement.destroy_all
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
			# Tournament
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
			button 				= (/Seat #([\d]*?) is the button/).match(hand_txt)[1]
			existing_hand = Hand.joins(table: :tournament).where("hands.uid = ? AND tables.id = ? AND tournaments.id = ?", hand_id, table.id, tournament.id).first

			unless existing_hand.present?
				hand = Hand.create(uid: hand_id, table: table, button: button)
				puts hand.inspect

				hero_name = (/Dealt to (...*?) /).match(hand_txt)[1]
				puts "HERO #{ hero_name }"
				hero_glove = (/Dealt to #{ hero_name } \[(...*?)\]/).match(hand_txt)[1]
				puts "DEALT #{ hero_glove }"

				puts "CARD 1 #{ hero_glove[0] }#{ hero_glove[1] }"
				puts "CARD 2 #{ hero_glove[3] }#{ hero_glove[4] }"

				(1..tournament.table_max).each do |num|
					seat_name = (/Seat #{ num }: (...*?) /).match(hand_txt).to_a[1]

					if seat_name.present?
						start_chips = (/Seat #{ num }: #{ seat_name.strip } \((...*?) in chips/).match(hand_txt).to_a[1]					
						player 			= Player.where("name = ?", seat_name).first_or_create!(name: seat_name)
						puts player.inspect
						ticket 			= Ticket.where("tournament_id = ? AND player_id = ?", tournament.id, player.id).first_or_create!(tournament: tournament, player: player)
						puts ticket.inspect
						placement 	= Placement.where("player_id = ? AND hand_id = ?", player.id, hand.id).first_or_create!(player: player, hand: hand, start_chips: start_chips, seat: num)
						puts placement.inspect

						puts seat_name
						player_glove = (/#{ seat_name }: shows \[(...*?)\]/).match(hand_txt).to_a[1]

						if player_glove.present?
							puts "########"
							puts "GLOVE #{ player_glove }"
							puts "########"

							card_3 = Card.create!(suite: player_glove[1], val: player_glove[0], placement: placement)
							card_4 = Card.create!(suite: player_glove[4], val: player_glove[3], placement: placement)

							puts card_3.inspect
							puts card_4.inspect
						end

						if seat_name == hero_name
							puts "########"
							puts "HERO"
							puts "########"

							# first or create here
							card_1 = Card.create!(suite: hero_glove[1], val: hero_glove[0], placement: placement)
							card_2 = Card.create!(suite: hero_glove[4], val: hero_glove[3], placement: placement)

							puts card_1.inspect
							puts card_2.inspect
						end
					end

					puts "tournament players count #{ tournament.players.count }"
				end
			end

			puts "###################################################################################################"
		end
	end
end