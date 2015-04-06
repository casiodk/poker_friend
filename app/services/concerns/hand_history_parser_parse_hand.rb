# -*- encoding : utf-8 -*-
module HandHistoryParserParseHand
  extend ActiveSupport::Concern
  included do
    include HandHistoryParserParseSetup
    
    attr_reader :hand_txt

  private
    def parse_hand(hand_txt)
      begin
        reset_parse_hand
        set_hand_txt(hand_txt)
        parse_setup
        
        # parse_preflop
        # parse_flop
        # parse_turn
        # parse_river
        # parse_showdown
        # parse_summary

        
        #set_hero_name
        #set_hero_glove
        # set_player_glove
        # create_player_glove
        #@hero_name    = nil
        #@hero_glove   = nil
        # @player_glove       = nil
        #attr_reader  :hero_name, :hero_glove

        # parse_preflop_actions
        # parse_flop_actions
        # parse_turn_actions
        # parse_river_actions

      rescue RuntimeError => error
        puts error
      end
    end

    def reset_parse_hand
      @hand_txt     = nil
    end

    def set_hand_txt(hand_txt)
      @hand_txt = hand_txt

      runtime_error("hand_txt not present") unless hand_txt.present?
    end

    def first_or_create_round(stage, position)
      Round.joins(:hand).where("stage = ? AND hands.id = ?", stage, hand.id).first_or_create!(stage: stage, hand: hand, position: position)
    end

    # NOT REFACTORED
    attr_reader :player_glove

    def set_hero_name
      @hero_name = (/Dealt to (...*?) /).match(hand_txt)[1]
    end

    def set_hero_glove
      @hero_glove = (/Dealt to #{ hero_name } \[(...*?)\]/).match(hand_txt)[1]
    end

    def set_player_glove
      @player_glove = (/#{ escaped_seat_name }: shows \[(...*?)\]/).match(hand_txt).to_a[1]
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
      round = first_or_create_round("preflop", 0)

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
        
        player            = (/^(...*?):/).match(action_txt).to_a[1]
        whole_action_txt  = (/:(...*?)$/).match(action_txt).to_a[1].to_s.strip
        action            = (/(?:^|(?:[.!?]\s))(\w+)/).match(whole_action_txt).to_a[1]
        amount            = (/^[^\d]*(\d+)/).match(whole_action_txt).to_a[1]
        
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
end
