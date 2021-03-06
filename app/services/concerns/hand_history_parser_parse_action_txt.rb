# -*- encoding : utf-8 -*-
module HandHistoryParserParseActionTxt
  extend ActiveSupport::Concern
  included do
    attr_reader :action_txt, :action_txt_player_name, :whole_action_txt, :stripped_action, :amount, :action_txt_player, :action_txt_index

  private
   # maybe round as argument here
    def parse_action_txt(action_txt, index)
      begin
        reset_parse_action_txt
        set_action_txt(action_txt)
        set_action_txt_index(index)
        set_action_txt_player_name
        set_whole_action_txt
        set_stripped_action
        set_amount
        set_action_txt_player
        create_action
        reset_parse_action_txt
      rescue RuntimeError => error
        puts error
        reset_parse_action_txt
      end
      puts "------------------------------"
    end

    def reset_parse_action_txt
      @action_txt             = nil
      @action_txt_index       = 0
      @action_txt_player_name = nil
      @whole_action_txt       = nil
      @stripped_action        = nil
      @amount                 = nil
      @action_txt_player      = nil
    end

    def set_action_txt(action_txt)
      @action_txt = action_txt
      puts "action_txt:#{ action_txt }"
      runtime_error("action_txt not present") unless action_txt.present?
    end

    def set_action_txt_index(index)
      @action_txt_index = index
      puts "action_txt_index:#{ action_txt_index }"
      runtime_error("action_txt_index not present") unless action_txt_index.present?
    end

    def set_action_txt_player_name
      @action_txt_player_name = (/^(...*?):/).match(action_txt).to_a[1]
      # puts "action_txt_player_name:#{ action_txt_player_name }"
      runtime_error("action_txt_player_name not present") unless action_txt_player_name.present?
    end

    def set_whole_action_txt
      @whole_action_txt = (/:(...*?)$/).match(action_txt).to_a[1].to_s.strip
      # puts "whole_action_txt:#{ whole_action_txt }"
      runtime_error("whole_action_txt not present") unless whole_action_txt.present?
    end

    def set_stripped_action
      @stripped_action = (/(?:^|(?:[.!?]\s))(\w+)/).match(whole_action_txt).to_a[1]

      # puts "stripped_action:#{ stripped_action }"
      runtime_error("stripped_action not present") unless stripped_action.present?
    end

    def set_amount
      @amount = (/^[^\d]*(\d+)/).match(whole_action_txt).to_a[1]
      # puts "amount:#{ amount }"
    end

    def set_action_txt_player
      @action_txt_player = hand.players.where("players.name = ?", action_txt_player_name).first

      # puts "action_txt_player:#{ action_txt_player.inspect }"
      runtime_error("could not find action_txt_player with action_txt_player_name:#{ action_txt_player_name }") unless action_txt_player
    end

    def create_action
      pl = Placement.joins(:player, :hand).where("players.name = ? AND hands.id = ?", action_txt_player_name, hand.id).first

      runtime_error("could not find placement from  action_txt_player_name, hand.id") unless pl

      a = Action.joins(:round, :placement).where("actions.position = ? AND rounds.id = ? AND placements.id = ?", action_txt_index, parse_preflop_round.id, pl.id).first_or_create(position: action_txt_index, round: parse_preflop_round, placement: pl, action: stripped_action, action_txt: whole_action_txt, amount: amount)

      puts "ACTION: #{ a.inspect }"
      runtime_error("could not find create action") unless a
    end
  end
end
