# -*- encoding : utf-8 -*-
module HandHistoryParserParseSeat
  extend ActiveSupport::Concern
  included do
    attr_reader :num, :seat_name, :escaped_seat_name, :player, :ticket, :start_chips, :placement

  private
    def parse_seat(num)
      begin
        reset_parse_seat
        set_num(num)
        set_seat_name
        set_escaped_seat_name
        set_player
        set_ticket
        set_start_chips
        set_placement
      rescue RuntimeError => error
        puts error
      end
    end

    def reset_parse_seat
      @num                = nil
      @seat_name          = nil
      @escaped_seat_name  = nil
      @player             = nil
      @ticket             = nil
      @start_chips        = nil
      @placement          = nil
    end

    def set_num(num)
      @num = num
      # puts "num:#{ num }"
      runtime_error("num not present") unless num.present?
    end

    def set_seat_name
      @seat_name = (/Seat #{ num }: (...*?) /).match(setup_txt).to_a[1]
      # puts "seat_name:#{ seat_name }"
      runtime_error("seat_name could not be found with num #{ num }") unless seat_name.present?
    end

    def set_escaped_seat_name
      @escaped_seat_name = seat_name.strip.gsub(".", "\\.").gsub("^", "\\^").gsub("$", "\\$").gsub("*", "\\*").gsub("+", "\\+").gsub("?", "\\?").gsub("(", "\\(").gsub(")", "\\)").gsub("[", "\\[").gsub("{", "\\{").gsub("|", "\\|")
    end

    def set_player
      @player = Player.where("name = ?", seat_name).first_or_create!(name: seat_name)
      # puts "player:#{ player.inspect }"
      runtime_error("Could not find_or_create player with seat_name: #{ seat_name }") unless player
    end

    def set_ticket
      @ticket = Ticket.where("tournament_id = ? AND player_id = ?", tournament.id, player.id).first_or_create!(tournament: tournament, player: player)
      # puts "ticket:#{ ticket.inspect }"
      runtime_error("Could not find_or_create ticket with tournament_id: #{ tournament.id } AND player_id: #{ player.id }") unless ticket
    end

    def set_start_chips
      @start_chips = (/Seat #{ num }: #{ escaped_seat_name.strip } \((...*?) in chips/).match(setup_txt).to_a[1]
      # puts "start_chips:#{ start_chips }"
      runtime_error("Could not set start_chips for seat_name: #{ escaped_seat_name } AND num #{ num }") unless start_chips.present?
    end

    def set_placement
      @placement  = Placement.where("player_id = ? AND hand_id = ?", player.id, hand.id).first_or_create!(player: player, hand: hand, start_chips: start_chips, seat: num)
      # puts "placement:#{ placement.inspect }"
      runtime_error("Could not find_or_create placement with player.id: #{ player.id } AND hand.id: #{ hand.id }") unless placement
    end
  end
end
