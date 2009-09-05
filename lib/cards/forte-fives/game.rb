require 'cards/cards'
require 'orderedhash'
require 'ruby-debug'

module ForteFives
  include PlayingCards

  class Trick 
    attr_accessor :lead, :trump, :plays

    def self.create_ranks suite, rank, start
        Hash[
          [(start...start+rank.size).to_a, rank].
            transpose.
            collect {|order,rank| [[suite, rank.to_sym], order]}
        ]
    end

    VALS = {
      :trump => {
        :hearts => self.create_ranks( 
          :hearts, 
          %w{five jack ace king queen ten nine eight seven six four three two},
          0
        ),
        :diamonds => {
          [:diamonds, :five]  =>  0,
          [:diamonds, :jack]  =>  1,
          [:hearts,   :ace]   =>  2,
        }.merge(self.create_ranks(
          :diamonds, 
          %w{ace king queen ten nine eight seven six four three two},
          3
        )),
        :clubs => {
          [:clubs,    :five]  =>  0,
          [:clubs,    :jack]  =>  1,
          [:hearts,   :ace]   =>  2
        }.merge(self.create_ranks(
          :clubs,
          %w{ace king queen two three four six seven eight nine ten},
          3
        )),
        :spades => {
          [:spades,   :five]  =>  0,
          [:spades,   :jack]  =>  1,
          [:hearts,   :ace]   =>  2,
        }.merge(self.create_ranks(
          :spades,
          %w{ace king queen two three four six seven eight nine ten},
          3
        )),
      },
      :off_suite => {
        :hearts => self.create_ranks(
          :hearts,
          %w{king queen jack ten nine eight seven six five four three two},
          14
        ),
        :diamonds => self.create_ranks(
          :diamonds,
          %w{king queen jack ten nine eight seven six five four three two ace},
          14
        ),
        :clubs => self.create_ranks( 
          :clubs, 
          %w{king queen jack ace two three four five six seven eight nine ten},
          14
        ),
        :spades => self.create_ranks( 
          :spades, 
          %w{king queen jack ace two three four five six seven eight nine ten},
          14
        )
      }
    }

    def initialize trump
      @trump = trump
      @plays = []
    end

    def lead
      plays.first
    end

    def add player, card
      plays << [player, card]
    end

    def winner
      sort_order = VALS[:trump][trump].clone
      sort_order.default=100
      unless lead and sort_order[lead[1].split] < 30
        sort_order.merge! VALS[:off_suite][lead[1].suite]
      end
      sort_order.default = 100
      plays.sort do |a,b|
        sort_order[a[1].split] <=> sort_order[b[1].split]
      end.first
    end

    def to_s
      "<Trick plays: #{plays}, winner: #{winner}>"
    end
  end

  class Kitty < CardArray
    alias :oldtake :take

    def take *cards
      csize = 1
      if cards.respond_to?:size
        csize = cards.size
      end
      if csize + size > 3
        raise "Kitty can only have 3 cards"
      end
      oldtake cards
    end
  end

  class Card < PlayingCards::Card
    def to_s
      v = case val
      when :two, :three, :four, :five, :six, :seven, :eight, :nine
        (14-PlayingCards::VALUES.index(val)).to_s
      when :ace
        "a"
      else
        val.to_s[0..0]
      end
      "#{v.upcase}#{suite.to_s[0..0]}"
    end

    def split
      return suite, val
    end

    def rank trump
      vals = Trick::VALS[:trump][trump].clone
      Trick::VALS[:off_suite].each do |k,v|
        vals.merge! v unless k == trump
      end
      vals[split]
    end

    # This method assumes that there are only cards of the same suite
    # in VALS[:off_suite][suite], but it does not assume it for :trump.
    # This is to accomidate the AofH
    def compare other, trump=nil
      trump_vals = Trick::VALS[:trump][trump] || {[:hearts, :ace] => 3}
      offsuite_vals = Trick::VALS[:off_suite][suite]
      raise 'fuck' unless trump_vals and offsuite_vals
      suites = PlayingCards::SUITES
      me = [suite, val]
      you = [other.suite, other.val]

      # if the card is in the trump
      if trump_vals[me]
        # and other is too
        if trump_vals[you]
          trump_vals[me] <=> trump_vals[you]
        #only self is in trump
        else
          -1
        end
      # else, if only other is in trump
      elsif trump_vals[you]
        1
      # else, if they are in the same off suite
      elsif offsuite_vals[you]
        offsuite_vals[me] <=> offsuite_vals[you]
      # doesn't really matter, but group by suite
      else
        suites.index(suite) <=> suites.index(other.suite)
      end
    end
  end

  class Team
    attr_reader :players

    def initialize *players
      players.each {|p| p.team = self}
      @players = players
    end

    def replace old, new
      players[players.index(old)] = new
      old.team = nil
      new.team = self
    end

    def to_s
      players.collect {|p| p.name}.join("+")
    end
  end


  class Score
    attr_reader :rounds, :curr_round
    # ex.
    # [
    #   {team1 => 15, team2 => 15},
    #   {team1 => -15, team2 => 20}
    # ]
    def initialize game
      @game = game
      @rounds = []
    end

    def next_round 
      @curr_round = Hash.new(0)
      @rounds << @curr_round
    end

    def add_score team, points
      curr_round[team] += points
    end

    def curr_total
      @rounds.inject(Hash.new(0)) {|t, r| r.each {|k,v| t[k] += v}; t}
    end

    # utility to wrap negative scores in ()
    # max is how many digits the field can hold.
    # 2 for the left hand col and 3 for the right
    def i_to_s i, max=2
      if i < 0
        "(%#{max}d)"%[i.abs]
      else
        # space to align with hole scores
        "#{i} "
      end
    end

    def to_s
      out = []
      teams = @game.teams
      colsize = [teams.max {|a,b| a.to_s.size <=> b.to_s.size}.to_s.size + 2, 12].max
      header = teams.map {|t| t.to_s.center(colsize)}.join('|')
      out << header
      out << '-'*header.size
      total = Hash.new(0)
      out << @rounds.map do |e| 
        teams.map do |t|
          total[t] += e[t]
          ("%4s - %5s"%[i_to_s(e[t]), i_to_s(total[t], 3)]).center(colsize)
        end.join('|')
      end
    end
  end

  class Game
    attr_reader :seat_count, :seats, :team_size, :game_over, :teams, :kitty
    attr_reader :score

    KITTY_SIZE = 3
    HAND_SIZE = 5

    RULES = {
      :reneg_five => true,
      :reneg_jack => true,
      :highest_bonus => true,
      :winner_must_bid => false,
      :hole_player_can_bid => false,
    }

    DEFAULTS = {
      :score_class => Score,
      :player_class => Player,
      :team_class => Team,
      :trick_class => Trick,
      :card_array_class => PlayingCards::CardArray,
      :team_size => 1,
      :rules => RULES,
    }

    BIDS = {
      nil => 0,
      :pass => 0,
      15 => 15,
      20 => 20,
      25 => 25,
      30 => 30,
      :thirty_for_sixty => 60,
      :thirty_for_one_twenty => 120
    }

    # opts = {
    #   :seat_count,
    #   [:team_size],
    #   [:players],
    #   [:rules],
    #   [:score_class],
    #   [:team_class],
    #   [:trick_class],
    #   [:player_class],
    # }
    def initialize opts
      opts = DEFAULTS.clone.merge(opts)
      unless opts[:seat_count]
        raise "opts must have seat_count attr"
      end
      %w{score team player trick card_array}.each do |k|
        instance_variable_set "@#{k}_class", opts["#{k}_class".to_sym]
      end
      @seat_count = opts[:seat_count]
      @team_size = opts[:team_size]
      @seats = []
      unless (@seat_count % @team_size).zero?
        raise "seat_count(#{@seat_count}) must be a " +
              "multiple of team_size(#{@team_size})"
      end
      @rules = opts[:rules] 
      players = opts[:players] || 
        (1..@seat_count).map {|i| @player_class.new("player #{i}", self)}
      players.each {|p| p.game = self}
      players = players.map {|p| if p; p; else; @player_class.new "player #{i}"; end}
      if players.size < @seat_count
        (players.size..@seat_count).each do |i| 
          players << @player_class.new("player #{i}")
        end
      elsif players.size > @seat_count
        raise "too many players, not enough seats"
      end

      players.each_with_index {|p, i| @seats[i] = p}
      @teams = @seats.group_by.with_index do |_,i| 
        i % (@seat_count / @team_size)
      end.collect {|_,v| @team_class.new *v}

      @score = @score_class.new self
      self
    end

    def new_card_array
      @card_array_class.new
    end

    def deal dealer
      @deck = PlayingCards.std_deck(Card).shuffle
      @kitty = Kitty.new
      @kitty.take @deck.pop KITTY_SIZE
      seats.each {|p|
        p.take @deck.pop HAND_SIZE
      }
      event :dealt, dealer
    end

    # get the players in order around the table, starting with a certain seat 
    def ordered_players starting_with_seat
      ret = []
      0.upto(@seat_count-1) do |i|
        idx = (i+starting_with_seat) % @seat_count
        if block_given?
          yield idx, seats[idx]
        end
        ret << seats[idx]
      end
      ret
    end

    def get_bid
      history = []
      high = {}
      ordered_players(seats.index(dealer) + 1 % @seat_count) do |i,p|
        possible_bids = Hash[BIDS.select {|_,v| v > BIDS[high[:bid]]}].merge :pass => 0
        bid = p.bid history, possible_bids, p == dealer
        unless possible_bids.keys.find {|b| b == bid}
          raise "Bid #{bid} not possible for #{history}"
        end
        event :bid, p, bid
        history << {:player => p, :bid => bid}
        if BIDS[bid] > BIDS[high[:bid]]
          high = {:bid => bid, :player => p}
        end
      end
      if BIDS[high[:bid]] < 15
        high = {:player => dealer, :bid => 15}
      end
      event :bid_won, high[:player], high[:bid]
      return high[:player], high[:bid], history
    end

    def event type, *args
      #puts ":#{type}( #{args.join(', ')} )"
    end

    def valid_cards trick, hand
      trump_cards = Trick::VALS[:trump][trick.trump]
      if trick.lead and trump_cards[trick.lead[1].split]
        # must throw trump if we have it
        cards = hand.select do |c|
          trump_cards[c.split] 
        end
        if cards.empty?
          hand
        else
          cards
        end
      else
        hand
      end
    end

    def valid_card trick, hand, card
      valid_cards(trick, hand).find {|c| c == card}
    end

    def next_dealer
      if @curr_dealer_idx
        # iter dealer
        @curr_dealer_idx += 1
        @curr_dealer_idx %= @seat_count
      else
        # randomly assign first dealer
        @curr_dealer_idx = rand(@seat_count)
      end
      seats[@curr_dealer_idx]
    end

    def dealer
      if @curr_dealer_idx
        seats[@curr_dealer_idx]
      else
        next_dealer
      end
    end

    def play_hand bidder, bid, trump
      # play hand
      tricks = []
      # lead is the first to throw a card on the trick
      next_lead = @seats.index(bidder)

      # for each hand, play the trick
      HAND_SIZE.times do 
        t = @trick_class.new(trump)
        ordered_players(next_lead) do |_,player|
          card = nil
          hand_before = player.hand.clone
          until card and valid_card t, hand_before, card
            hand_before = player.hand.clone
            player.take card if card
            card = player.play t
            unless valid_card t, hand_before, card
              event :bad_card_played, player, card
            end
          end
          t.add player, card
          event :card_played, player, card
        end
        event :trick_played, t
        tricks << t
        next_lead = seats.index(t.winner[0])
      end
      event :hand_played, tricks
      tricks
    end
        
    def next_round
      # get bids
      deal next_dealer
      bidder, bid, _ = get_bid 

      trump = bidder.trump
      event :trump_choosen, bidder, trump

      bidder.take *kitty
      event :kitty_taken, bidder, kitty

      first = (@seats.index(dealer)+1) % @seat_count

      # discard
      ordered_players first do |i, p| 
        event :discard, p, p.discard(trump, 1)
        if p.hand.size > 5 or p.hand.size < 1
          raise "player: #{p} has an illegal size hand"
        end
      end

      # redeal missing cards
      ordered_players first do |i, p| 
        needs = 5 - p.hand.size
        if needs > 0
          p.take @deck.pop needs
        end
        event :redeal, p, needs
      end

      tricks = play_hand bidder, bid, trump

      score.next_round
      tricks.each do |t|
        score.add_score(t.winner[0].team, 5)
      end
      score.add_score(highest_trick(trump, tricks).winner[0].team, 5)
      if score.curr_round[bidder.team] < bid
        score.curr_round[bidder.team] = -bid
      end
    end

    def highest_trick trump, tricks
      fake_trick = Trick.new trump
      tricks.each do |t|
        fake_trick.add *t.winner
      end
      tricks.find do |t|
        t.plays.find {|c| c == fake_trick.winner}
      end
    end

    def game_over?
      @score.curr_total.find {|k, v| v >= 120}
    end
  end
end
