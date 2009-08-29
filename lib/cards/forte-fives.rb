require 'cards/cards'

module ForteFives
  include PlayingCards

  class Trick < CardArray
    def self.create_ranks suite, rank, start
        Hash[
          [(start...start+rank.size).to_a, rank].
            transpose.
            collect {|order,rank| [[:spades, rank.to_sym], order]}
        ]
    end

    VALS = {
      :trump => {
        :hearts => {
          [:hearts,   :five]  =>  0,
          [:hearts,   :jack]  =>  1,
          [:hearts,   :ace]   =>  2,
          [:hearts,   :king]  =>  3,
          [:hearts,   :queen] =>  4,
          [:hearts,   :ten]   =>  5,
          [:hearts,   :nine]  =>  6,
          [:hearts,   :eight] =>  7,
          [:hearts,   :seven] =>  8,
          [:hearts,   :six]   =>  9,
          [:hearts,   :four]  => 10,
          [:hearts,   :three] => 11,
          [:hearts,   :two]   => 12
        },
        :diamonds => {
          [:diamonds, :five]  =>  0,
          [:diamonds, :jack]  =>  1,
          [:hearts,   :ace]   =>  2,
          [:diamonds, :ace]   =>  3,
          [:diamonds, :king]  =>  4,
          [:diamonds, :queen] =>  5,
          [:diamonds, :ten]   =>  6,
          [:diamonds, :nine]  =>  7,
          [:diamonds, :eight] =>  8,
          [:diamonds, :seven] =>  9,
          [:diamonds, :six]   => 10,
          [:diamonds, :four]  => 11,
          [:diamonds, :three] => 12,
          [:diamonds, :two]   => 13
        },
        :clubs => {
          [:clubs,    :five]  =>  0,
          [:clubs,    :jack]  =>  1,
          [:hearts,   :ace]   =>  2,
          [:clubs,    :ace]   =>  3,
          [:clubs,    :king]  =>  4,
          [:clubs,    :queen] =>  5,
          [:clubs,    :two]   =>  6,
          [:clubs,    :three] =>  7,
          [:clubs,    :four]  =>  8,
          [:clubs,    :six]   =>  9,
          [:clubs,    :seven] => 10,
          [:clubs,    :eight] => 11,
          [:clubs,    :nine]  => 12,
          [:clubs,    :ten]   => 13
        },
        :spades => {
          [:spades,   :five]  =>  0,
          [:spades,   :jack]  =>  1,
          [:hearts,   :ace]   =>  2,
          [:spades,   :ace]   =>  3,
          [:spades,   :king]  =>  4,
          [:spades,   :queen] =>  5,
          [:spades,   :two]   =>  6,
          [:spades,   :three] =>  7,
          [:spades,   :four]  =>  8,
          [:spades,   :six]   =>  9,
          [:spades,   :seven] => 10,
          [:spades,   :eight] => 11,
          [:spades,   :nine]  => 12,
          [:spades,   :ten]   => 13
        }
      },
      :off_suite => {
        :hearts => {
          [:hearts,   :king]  => 14,
          [:hearts,   :queen] => 15,
          [:hearts,   :jack]  => 16,
          [:hearts,   :ten]   => 17,
          [:hearts,   :nine]  => 18,
          [:hearts,   :eight] => 19,
          [:hearts,   :seven] => 20,
          [:hearts,   :six]   => 21,
          [:hearts,   :five]  => 22,
          [:hearts,   :four]  => 23,
          [:hearts,   :three] => 24,
          [:hearts,   :two]   => 25
        },
        :diamonds => {
          [:diamonds, :king]  => 14,
          [:diamonds, :queen] => 15,
          [:diamonds, :jack]  => 16,
          [:diamonds, :ten]   => 17,
          [:diamonds, :nine]  => 18,
          [:diamonds, :eight] => 19,
          [:diamonds, :seven] => 20,
          [:diamonds, :six]   => 21,
          [:diamonds, :five]  => 22,
          [:diamonds, :four]  => 23,
          [:diamonds, :three] => 24,
          [:diamonds, :two]   => 25,
          [:diamonds, :ace]   => 26
        },
        :clubs => {
          [:clubs,    :king]  => 14,
          [:clubs,    :queen] => 15,
          [:clubs,    :jack]  => 16,
          [:clubs,    :ace]   => 17,
          [:clubs,    :two]   => 18,
          [:clubs,    :three] => 19,
          [:clubs,    :four]  => 20,
          [:clubs,    :five]  => 22,
          [:clubs,    :six]   => 22,
          [:clubs,    :seven] => 23,
          [:clubs,    :eight] => 24,
          [:clubs,    :nine]  => 25,
          [:clubs,    :ten]   => 26,
        },
        :spades => self.create_ranks( 
          :spades, 
          %w{king queen jack ace two three four five six seven eight nine ten},
          14
        )
      }
    }


    def initialize trump
      @trump = trump
      @cards = {}
    end

    def add card, player
      @led = card if @cards.empty?
      @cards[card] = player
    end

    def winner
      @cards[winning_card]
    end

    def winning_card
      sort_order = Hash.new(100)
      sort_order.merge! VALS[:off_suite][@led.suite] if @led.suite != @trump
      if @cards.keys.find {|k| k.suite == @trump}
        sort_order.merge! VALS[:trump][@trump]
      end
      @cards.keys.sort do |i,j|
        sort_order[[i.suite, i.val]] <=> sort_order[[j.suite, j.val]]
      end.first
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

  class PlayerHand < CardArray
  end

  class Player
    attr_reader :name
    attr_accessor :team

    def initialize name
      @name = name
    end
  end

  class Team
    attr_reader :players

    def initialize *players
      players.each {|p| p.team = self}
      @players = players
    end

    def replace old, new
      @players[@players.index(old)] = new
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
    attr_reader :seat_count, :seats, :team_size, :game_over, :teams

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
      :team_size => 1,
      :rules => RULES,
    }

    # opts = {
    #   :seat_count,
    #   :team_size,
    #   [:players],
    #   [:rules],
    # }
    def initialize opts
      opts = DEFAULTS.clone.merge(opts)
      unless opts[:seat_count]
        raise "opts must have seat_count attr"
      end
      @score_class = opts[:score_class] 
      @team_class = opts[:team_class] 
      @player_class = opts[:player_class] 
      @trick_class = opts[:trick_class] 
      @seat_count = opts[:seat_count]
      @team_size = opts[:team_size]
      @seats = []
      unless (@seat_count % @team_size).zero?
        raise "seat_count(#{@seat_count}) must be a " +
              "multiple of team_size(#{@team_size})"
      end
      @rules = opts[:rules] 
      @score = Hash.new(0)
      @teams = []
      players = opts[:players] || 
        (1..@seat_count).map {|i| @player_class.new("player #{i}")}
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
        i % @team_size 
      end.collect {|k,v| @team_class.new *v}

      @score = @score_class.new self
      self
    end

    def ordered_players starting_with_seat
      0.upto(@seat_count-1) do |i|
        idx = i+starting_with_seat % @seat_count
        yield @seats[idx]
      end
    end
        
    def next_round
      # get bids
      @next_dealer_idx ||= 0
      highest_bid = nil
      order_players @next_dealer_idx+1 do |player|
        highest_bid = player.bid(*highest_bid) || highest_bid
      end

      # play round
      tricks = []
      next_lead = @seats.index(highest_bid[:player])
      5.times do 
        t = @trick_class.new(highest_bid[:trump])
        order_players(next_lead) do |player|
          player.play(t)
        end
        tricks << t
        next_lead = @seats.index(t.winner)
      end

      # score round
      highest_trick = tricks.max {|a,b| a.winning_card <=> b.winning_card}
      0.upto(@seat_count-1) {|i| @score[i] << 0}
      tricks.each do |t|
        seat_idx = @seats.index(t.winner)
        @score[seat_idx].last += 5
        if t == highest_trick
          @score[seat_idx].last += 5
        end
      end
      # TODO: refactor for teams.  Score object?
      bidder_idx = @seats.index(highest_bid[:player])
      if @score[bidder_idx].last < highest_bid[:bid]
        @score[bidder_idx].last = -highest_bid[:bid]
      end

      # check for winner
      # TODO: refactor for teams. Score object?
      game_over = false
      0.upto(@seat_count-1) do |i|
        if @score[i].inject(0) {|s,i| s+i} >= 120
          game_over = true
        end
      end

      if game_over
        winner = @score.index(
          @score.max do |a,b|
            a.inject(0) {|s,i| s+i} <=> b.inject(0) {|s,i| s+i}
          end
        )
      end
    end
  end

end
