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
        
        # parse_flop
        # parse_turn
        # parse_river
        # parse_showdown
        # parse_summary

        # set_player_glove
        # create_player_glove
        # @player_glove       = nil

        # parse_flop_actions
        # parse_turn_actions
        # parse_river_actions
        reset_parse_hand
      rescue RuntimeError => error
        puts error
        reset_parse_hand
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

    def create_glove(glove="", name="")
      if glove.present? && name.present?
        pl = Placement.joins(:player, :hand).where("players.name = ? AND hands.id = ?", name, hand.id).first
        
        if pl.present? && glove.present? && pl.cards.empty?
          c1 = Card.create!(val: hero_glove[0], suite: hero_glove[1], placement: pl)
          c2 = Card.create!(val: hero_glove[3], suite: hero_glove[4], placement: pl)

          puts "placement: #{ pl.inspect }"
          puts "CARD 1 #{ c1.inspect }"
          puts "CARD 2 #{ c2.inspect }"
        end
      end
    end

    # NOT REFACTORED
    attr_reader :player_glove

    def set_player_glove
      @player_glove = (/#{ escaped_seat_name }: shows \[(...*?)\]/).match(hand_txt).to_a[1]
    end
  end
end
