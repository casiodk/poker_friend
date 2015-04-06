# -*- encoding : utf-8 -*-
module HandHistoryParserParseSetup
  extend ActiveSupport::Concern
  included do
    include HandHistoryParserParseSeat
    attr_reader :setup_txt, :table_max, :tournament, :table, :button, :hand

  private
    def parse_setup
      reset_parse_setup
      set_setup_txt
      set_table_max
      set_tournament
      set_table
      set_button
      set_hand
      parse_seats
      # Blinds actions MISSING
    end

    def reset_parse_setup
      @setup_txt  = nil
      @table_max  = nil
      @tournament = nil
      @table      = nil
      @button     = nil
      @hand       = nil
    end

    def set_setup_txt
      @setup_txt = (/PokerStars (...*?)\*\*\* HOLE CARDS \*\*\*/m).match(hand_txt).to_a[1]
      # puts setup_txt
      runtime_error("setup_txt not present") unless setup_txt.present?
    end

    def set_table_max
      @table_max = (/' ([\d]*?)-max/).match(setup_txt)[1]
      # puts "table_max:#{ table_max }"
      runtime_error("table_max not present") unless table_max.present?
    end

    def set_tournament
      tournament_id = (/Tournament #([\d]*?),/).match(setup_txt)[1]
      @tournament   = Tournament.where("uid = ?", tournament_id).first_or_create(uid: tournament_id, table_max: table_max.to_i)
      # puts "tournament:#{ tournament.inspect }"
      runtime_error("Could not find_or_create tournament with tournament_id: #{ tournament_id }") unless tournament
    end

    def set_table
      table_id      = (/Table '([\d ]*?)'/).match(setup_txt)[1].remove(tournament.uid).strip
      @table        = Table.where("tournament_id = ? AND uid = ?", tournament.id, table_id).first_or_create(tournament: tournament, uid: table_id)
      # puts "table:#{ table.inspect }"
      runtime_error("Could not find_or_create table with table_id: #{ table_id }") unless table
    end

    def set_button
      @button = (/Seat #([\d]*?) is the button/).match(setup_txt)[1]
      # puts "button:#{ button }"
      runtime_error("button not present") unless button.present?
    end

    def set_hand
      hand_id       = (/Hand #([\d]*?):/).match(setup_txt)[1]
      
      existing_hand = Hand.joins(table: :tournament).where("hands.uid = ? AND tables.id = ? AND tournaments.id = ?", hand_id, table.id, tournament.id).first
      runtime_error("Hand ##{ existing_hand.id } uid: #{ existing_hand.uid } already processed") if existing_hand

      @hand         = Hand.create(uid: hand_id, table: table, button: button)
      # puts "hand:#{ hand.inspect }"
      runtime_error("Could not find_or_create hand with hand_id: #{ hand_id }") unless @hand
    end

    def parse_seats
      (1..tournament.table_max).each do |num|
        parse_seat(num)
      end
    end
  end
end
