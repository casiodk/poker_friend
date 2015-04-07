# -*- encoding : utf-8 -*-
module HandHistoryParserParseSeat
  extend ActiveSupport::Concern
  included do
    attr_reader :parse_seat_num, :parse_seat_name, :escaped_parse_seat_name, :parse_seat_player, :parse_seat_ticket, :parse_seat_start_chips, :parse_seat_placement

  private
    def parse_seat(num)
      begin
        reset_parse_seat
        set_parse_seat_num(num)
        set_parse_seat_name
        set_escaped_parse_seat_name
        set_parse_seat_player
        set_parse_seat_ticket
        set_parse_seat_start_chips
        set_parse_seat_placement
        reset_parse_seat
      rescue RuntimeError => error
        puts error
        reset_parse_seat
      end
    end

    def reset_parse_seat
      @parse_seat_num = nil
      @parse_seat_name = nil
      @escaped_parse_seat_name = nil
      @parse_seat_player = nil
      @parse_seat_ticket             = nil
      @parse_seat_start_chips        = nil
      @parse_seat_placement          = nil
    end

    def set_parse_seat_num(num)
      @parse_seat_num = num
      # puts "num:#{ num }"
      runtime_error("parse_seat_num not present") unless parse_seat_num.present?
    end

    def set_parse_seat_name
      @parse_seat_name = (/Seat #{ parse_seat_num }: (...*?) \(/).match(setup_txt).to_a[1]
      puts "parse_seat_name#{ parse_seat_name }"
      runtime_error("parse_seat_name could not be found with num #{ parse_seat_num }") unless parse_seat_name.present?
    end

    def set_escaped_parse_seat_name
      @escaped_parse_seat_name = parse_seat_name.strip.gsub(".", "\\.").gsub("^", "\\^").gsub("$", "\\$").gsub("*", "\\*").gsub("+", "\\+").gsub("?", "\\?").gsub("(", "\\(").gsub(")", "\\)").gsub("[", "\\[").gsub("{", "\\{").gsub("|", "\\|")
    end

    def set_parse_seat_player
      @parse_seat_player = Player.where("name = ?", parse_seat_name).first_or_create!(name: parse_seat_name)
      # puts "player:#{ player.inspect }"
      runtime_error("Could not find_or_create parse_seat_player with parse_seat_name: #{ parse_seat_name }") unless parse_seat_player
    end

    def set_parse_seat_ticket
      @parse_seat_ticket = Ticket.where("tournament_id = ? AND player_id = ?", tournament.id, parse_seat_player.id).first_or_create!(tournament: tournament, player: parse_seat_player)
      # puts "parse_seat_ticket:#{ parse_seat_ticket.inspect }"
      runtime_error("Could not find_or_create parse_seat_ticket with tournament_id: #{ tournament.id } AND player_id: #{ parse_seat_player.id }") unless parse_seat_ticket
    end

    def set_parse_seat_start_chips
      @parse_seat_start_chips = (/Seat #{ parse_seat_num }: #{ escaped_parse_seat_name.strip } \((...*?) in chips/).match(setup_txt).to_a[1]
      # puts "parse_seat_start_chips:#{ parse_seat_start_chips }"
      runtime_error("Could not set parse_seat_start_chips for parse_seat_name: #{ escaped_parse_seat_name } AND parse_seat_num #{ parse_seat_num }") unless parse_seat_start_chips.present?
    end

    def set_parse_seat_placement
      @parse_seat_placement  = Placement.where("player_id = ? AND hand_id = ?", parse_seat_player.id, hand.id).first_or_create!(player: parse_seat_player, hand: hand, start_chips: parse_seat_start_chips, seat: parse_seat_num)
      # puts "parse_seat_placement:#{ parse_seat_placement.inspect }"
      runtime_error("Could not find_or_create parse_seat_placement with player.id: #{ parse_seat_player.id } AND hand.id: #{ hand.id }") unless parse_seat_placement
    end
  end
end
