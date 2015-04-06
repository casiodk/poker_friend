# -*- encoding : utf-8 -*-
module HandHistoryParserParseHand
  extend ActiveSupport::Concern
  included do
    include HandHistoryParserParseSetup
    include HandHistoryParserParsePreflop
    
    attr_reader :hand_txt

  private
    def parse_hand(hand_txt)
      begin
        reset_parse_hand
        set_hand_txt(hand_txt)
        parse_setup
        parse_preflop
        
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


    def parse_flop_actions

    end

    def parse_turn_actions

    end

    def parse_river_actions

    end
  end
end
