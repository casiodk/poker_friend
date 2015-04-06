# -*- encoding : utf-8 -*-
module HandHistoryParserParsePreflop
  extend ActiveSupport::Concern
  included do
    include HandHistoryParserParseActionTxt
    attr_reader :preflop_txt, :round, :action_txts

  private
    def parse_preflop
      reset_parse_preflop
      set_preflop_txt
      set_round
      # hero glove
      set_action_txts
      parse_action_txts
      puts "---------------------------------------------------------------------"
    end

    def reset_parse_preflop
      @preflop_txt  = nil
      @round        = nil
      @action_txts  = []
    end

    def set_preflop_txt
      if (/\*\*\* FLOP \*\*\*(...*?)$/).match(hand_txt).to_a[1].present?
        @preflop_txt = (/\*\*\* HOLE CARDS \*\*\*(...*?)\*\*\* FLOP \*\*\*/m).match(hand_txt).to_a[1]
      else
        @preflop_txt = (/\*\*\* HOLE CARDS \*\*\*(...*?)\*\*\* SUMMARY \*\*\*/m).match(hand_txt).to_a[1]
      end

      # puts preflop_txt
      runtime_error("preflop_txt not present") unless preflop_txt.present?
    end

    def set_round
      @round = first_or_create_round("preflop", 0)

      # puts "round:#{ round.inspect }"
      runtime_error("Could not find_or_create round with hands.id: #{ hands.id } AND stage: preflop") unless round
    end

    def set_action_txts
      @action_txts = "#{ preflop_txt }".scan(/^.*:.*$/).reject { |action_txt| action_txt =~ /said, /i }
      # puts action_txts.join("|")
      runtime_error("action_txts not present") unless action_txts.any?
    end

    def parse_action_txts
      action_txts.each do |action_txt|
        parse_action_txt(action_txt)
      end
    end
  end
end
