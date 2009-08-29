# Klondike card game library in Ruby.
#
#  Copyright (C) 2009 Doki Pen <doki_pen@doki-pen.org>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA

require 'cards/cards'

module Klondike
  include PlayingCards 

  class KlondikeCard < Card
    COLORS = {
      :hearts => :red,
      :diamonds => :red,
      :spades => :black,
      :clubs => :black
    }

    VALS = {
      :two => 0,
      :three => 1,
      :four => 2,
      :five => 3,
      :six => 4,
      :seven => 5,
      :eight => 6,
      :nine => 7,
      :ten => 8,
      :jack => 9,
      :queen => 10,
      :king => 11,
      :ace => 12
    }

    def is_showing?
      @showing ||= false
    end

    def flip
      @showing = !is_showing?
      self
    end

    def combinable? other
      COLORS[suite] <=> COLORS[other.suite] and
        VALS[other.val] - VALS[val] == 1
    end

    def stackable? other
      COLORS[suite] == COLORS[other.suite] and
        VALS[val] - VALS[other.val] == 1
    end
  end

  # make sure cards are showing when combining
  # push(*other_stack) to combine
  class KlondikeStack < CardArray
    # Can we move one stack of cards onto another?
    #
    # XX 2C     
    # XX
    # 4H
    # 3S
    #
    # We can move the second stack onto the first
    def can_combine? other_stack
      (empty? and !other_stack.empty? and other_stack.first.val == :king) or 
        last.combinable? other_stack.first
    end

    def showing
      find_all {|c| c.showing?}
    end
  end

  # push cards onto home, but only if can_stack? returns true
  class KlondikeHome < CardArray
    def can_stack? card
      card.value == :ace or (last and last.stackable? card)
    end
  end

  class Game
    attr_reader :stacks, :homes, :deck, :discard, :recycle_count
    attr_accessor :recycle_limit

    include PlayingCards

    # takes hash, :recycle_limit and :deck (for testing)
    def initialize opts={}
      @recycle_count = 0
      @recycle_limit = opts[:recycle_limit] || 3
      @deck = opts[:deck] || PlayingCards.std_deck(KlondikeCard).shuffle
      @discard = CardArray.new
      homes = {
        :hearts => KlondikeHome.new,
        :diamonds => KlondikeHome.new,
        :spades => KlondikeHome.new,
        :clubs => KlondikeHome.new
      }
      @stacks = (1..7).collect do |st|
        ks = KlondikeStack.new
        st.times {ks.push d.shift}
        ks
      end
    end

    # flip a card off the top of the deck to the discard pile
    # discard.last will get the cards value, but it is also
    # returned.  If the deck is empty, the discard pile is 
    # recycled to the deck.  If the deck has been recycled
    # to the recycle_limit, then nil is returned
    def flip_deck
      if @deck.empty?
        if @recycle_count < @recycle_limit
          @deck = @discard.reverse.collect {|c| c.flip}
          @discard = CardArray.new
          @recycle_count += 1
        else
          nil
        end
      else
        @discard.push @deck.pop
      end
      @discard.first.flip
    end

    # flip the last card on a stack and return it
    # if it is already flipped, return nil
    def flip_stack stack
      if stack.last.is_showing?
        nil
      else
        stack.last.flip
      end
    end

    # move $count cards for source to target.  returns 
    # nil on failure.  
    # this will break if identical cards are in the source
    # stack
    def combine_stack target, source, count
      moving = source[-count..-1]
      nil if moving.empty? or moving.find {|c| !c.is_showing?}
      nil unless target.last.is_showing?
      if target.can_combine? moving
        source.replace(source - moving)
        target.push(*moving)
      else
        nil
      end
    end

    # try to send the last card in a stack to home
    # returns nil if it fails
    def send_home stack
      card = stack.last
      home = homes[card.suite]
      if card.is_showing? and home.can_stack? card
        home.push stack.pop
      else 
        nil
      end
    end
  end
end

