# -*- encoding : utf-8 -*-
module HandHistoryParserParsePreflop
  extend ActiveSupport::Concern
  included do
    include HandHistoryParserParseActionTxt
    attr_reader :parse_preflop_txt, :parse_preflop_round, :action_txts, :hero_name, :hero_glove

  private
    def parse_preflop
      reset_parse_preflop
      set_parse_preflop_txt
      set_parse_preflop_round
      set_hero_name
      set_hero_glove
      create_glove(hero_glove, hero_name)
      set_action_txts
      parse_action_txts
      reset_parse_preflop
      puts "---------------------------------------------------------------------"
    end

    def reset_parse_preflop
      @parse_preflop_txt  = nil
      @parse_preflop_round        = nil
      @action_txts  = []
      @hero_name    = nil
      @hero_glove   = nil
    end

    def set_parse_preflop_txt
      if (/\*\*\* FLOP \*\*\*(...*?)$/).match(hand_txt).to_a[1].present?
        @parse_preflop_txt = (/\*\*\* HOLE CARDS \*\*\*(...*?)\*\*\* FLOP \*\*\*/m).match(hand_txt).to_a[1]
      else
        @parse_preflop_txt = (/\*\*\* HOLE CARDS \*\*\*(...*?)\*\*\* SUMMARY \*\*\*/m).match(hand_txt).to_a[1]
      end

      # puts parse_preflop_txt
      runtime_error("parse_preflop_txt not present") unless parse_preflop_txt.present?
    end

    def set_parse_preflop_round
      @parse_preflop_round = first_or_create_round("preflop", 0)

      # puts "parse_preflop_round:#{ parse_preflop_round.inspect }"
      runtime_error("Could not find_or_create parse_preflop_round with hands.id: #{ hands.id } AND stage: preflop") unless parse_preflop_round
    end

    def set_hero_name
      @hero_name = (/Dealt to (...*?) /).match(parse_preflop_txt)[1]

      # puts "hero_name: #{ hero_name }"
    end

    def set_hero_glove
      @hero_glove = (/Dealt to #{ hero_name } \[(...*?)\]/).match(parse_preflop_txt)[1]

      # puts "hero_glove: #{ hero_glove }"
    end

    def set_action_txts
      @action_txts = "#{ parse_preflop_txt }".scan(/^.*:.*$/).reject { |action_txt| action_txt =~ /said, /i }
      # puts action_txts.join("|")
      runtime_error("action_txts not present") unless action_txts.any?
    end

    def parse_action_txts
      action_txts.each_with_index do |action_txt, index|
        parse_action_txt(action_txt, index)
      end
    end
  end
end
