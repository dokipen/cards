require 'cards/cards'
require 'orderedhash'
require 'ruby-debug'

module ForteFives
  include PlayingCards

  class Player
    attr_reader :name, :hand
    attr_accessor :game, :team

    def initialize name, game=nil
      @name = name
      @game = game
    end

    def play trick
      raise 'not supported'
    end

    def trump
      raise 'not supported'
    end

    def bid bid_history, possible_bids, dealer=false
      raise 'not supported'
    end

    def discard trump, keep_count=1
      raise 'not supported'
    end

    def to_s
      @last_trump ||= nil
      sorted_hand = @hand and @hand.sort{|a,b| a.compare b, @last_trump}.to_s
      "<Player name: #{name}, team: #{team or 'nil'}, cards: #{sorted_hand or '[]'}>"
    end

    def take *cards
      @hand ||= !game.nil? ? game.new_card_array : PlayingCards::CardArray.new
      @hand.take *cards
    end
  end

  class DumbAss < Player
    def bid _, possible_bids, dealer
      @last_trump = nil
      if dealer
        15
      else
        :pass
      end
    end

    def trump 
      @last_trump = :hearts
      :hearts
    end

    def discard trump, keep_count=1
      discard = hand.select {|c| c.rank(trump) > 13}
      if hand.size - discard.size >= keep_count and hand.size - discard.size <= 5
        @hand = PlayingCards::CardArray.new(@hand - discard)
      elsif hand.size - discard.size > 5
        new_hand = (@hand.sort{|a,b|a.rank(trump)<=>b.rank(trump)} - discard)
        discard += new_hand[5..-1]
        @hand = PlayingCards::CardArray.new(new_hand[0..4])
      else
        # keep $keep_count best cards
        new_hand = hand.sort do |a,b| 
          a.rank(trump) <=> b.rank(trump)
        end
        @hand = PlayingCards::CardArray.new(new_hand[0..keep_count-1])
        discard = new_hand[keep_count..-1]
      end
      discard
    end

    def play trick
      @last_trump = trick.trump
      valid_cards = game.valid_cards trick, hand
      card = valid_cards.sort {|a,b| a.compare(b, trick.trump)}.first
      hand.delete card
    end
  end
end
