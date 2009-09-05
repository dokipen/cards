require 'test/unit'
require 'cards/cards'
require 'cards/forte-fives'
require 'ruby-debug'

class TestForteFivesTrick < Test::Unit::TestCase
  include PlayingCards
  include ForteFives

  card_hash = Hash.new {|h,k| h.has_value?k.to_sym and k.to_sym or (h.has_key?k.to_s.downcase and h[k.to_s.downcase] or k)}

  SS = card_hash.clone.merge( 
    'h' => :hearts,
    's' => :spades,
    'c' => :clubs,
    'd' => :diamonds
  )

  VS = card_hash.clone.merge(
    'a' => :ace,
    '1' => :ace,
    '2' => :two,
    '3' => :three,
    '4' => :four,
    '5' => :five,
    '6' => :six,
    '7' => :seven,
    '8' => :eight,
    '9' => :nine,
    't' => :ten,
    'j' => :jack,
    'q' => :queen,
    'k' => :king
  )

  def C(suite, val=nil)
    val, suite = suite.split // unless val
    val, suite = VS[val], SS[suite]
    ForteFives::Card.new(suite, val)
  end

  def T(suite)
    Trick.new(SS[suite])
  end

  def test_card_to_s
    assert_equal 'Ad', C('Ad').to_s
    assert_equal '2d', C('2d').to_s
    assert_equal '3d', C('3d').to_s
    assert_equal '4d', C('4d').to_s
    assert_equal '5d', C('5d').to_s
    assert_equal '6d', C('6d').to_s
    assert_equal '7d', C('7d').to_s
    assert_equal '8d', C('8d').to_s
    assert_equal '9d', C('9d').to_s
    assert_equal 'Td', C('Td').to_s
    assert_equal 'Jd', C('Jd').to_s
    assert_equal 'Qd', C('Qd').to_s
    assert_equal 'Kd', C('Kd').to_s
    assert_equal 'As', C('As').to_s
    assert_equal '2s', C('2s').to_s
    assert_equal '3s', C('3s').to_s
    assert_equal '4s', C('4s').to_s
    assert_equal '5s', C('5s').to_s
    assert_equal '6s', C('6s').to_s
    assert_equal '7s', C('7s').to_s
    assert_equal '8s', C('8s').to_s
    assert_equal '9s', C('9s').to_s
    assert_equal 'Ts', C('Ts').to_s
    assert_equal 'Js', C('Js').to_s
    assert_equal 'Qs', C('Qs').to_s
    assert_equal 'Ks', C('Ks').to_s
    assert_equal 'Ac', C('Ac').to_s
    assert_equal '2c', C('2c').to_s
    assert_equal '3c', C('3c').to_s
    assert_equal '4c', C('4c').to_s
    assert_equal '5c', C('5c').to_s
    assert_equal '6c', C('6c').to_s
    assert_equal '7c', C('7c').to_s
    assert_equal '8c', C('8c').to_s
    assert_equal '9c', C('9c').to_s
    assert_equal 'Tc', C('Tc').to_s
    assert_equal 'Jc', C('Jc').to_s
    assert_equal 'Qc', C('Qc').to_s
    assert_equal 'Kc', C('Kc').to_s
    assert_equal 'Ah', C('Ah').to_s
    assert_equal '2h', C('2h').to_s
    assert_equal '3h', C('3h').to_s
    assert_equal '4h', C('4h').to_s
    assert_equal '5h', C('5h').to_s
    assert_equal '6h', C('6h').to_s
    assert_equal '7h', C('7h').to_s
    assert_equal '8h', C('8h').to_s
    assert_equal '9h', C('9h').to_s
    assert_equal 'Th', C('Th').to_s
    assert_equal 'Jh', C('Jh').to_s
    assert_equal 'Qh', C('Qh').to_s
    assert_equal 'Kh', C('Kh').to_s
  end

  def test_diamonds_trump
    p1 = Object.new
    def p1.to_s; 'p1'; end
    p2 = Object.new
    def p2.to_s; 'p2'; end

    t = T(:diamonds)
    t.add(p1, C('5d'))
    t.add(p2, C('jd'))
    assert_equal p1, t.winner[0]
    assert_equal C('5d'), t.winner[1]

    t = T(:diamonds)
    t.add(p1, C('jd'))
    t.add(p2, C('ah'))
    assert_equal p1, t.winner[0]
    assert_equal C('jd'), t.winner[1]

    t = T(:diamonds)
    t.add(p1, C(:hearts, :ace))
    t.add(p2, C(:diamonds, :ace))
    assert_equal p1, t.winner[0]
    assert_equal C(:hearts, :ace), t.winner[1]

    t = T(:diamonds)
    t.add(p1, C(:diamonds, :ace))
    t.add(p2, C(:diamonds, :king))
    assert_equal p1, t.winner[0]
    assert_equal C(:diamonds, :ace), t.winner[1]

    t = T(:diamonds)
    t.add(p1, C(:diamonds, :king))
    t.add(p2, C(:diamonds, :queen))
    assert_equal p1, t.winner[0]
    assert_equal C(:diamonds, :king), t.winner[1]

    t = T(:diamonds)
    t.add(p1, C(:diamonds, :queen))
    t.add(p2, C(:diamonds, :ten))
    assert_equal p1, t.winner[0]
    assert_equal C(:diamonds, :queen), t.winner[1]

    t = T(:diamonds)
    t.add(p1, C(:diamonds, :ten))
    t.add(p2, C(:diamonds, :nine))
    assert_equal p1, t.winner[0]
    assert_equal C(:diamonds, :ten), t.winner[1]

    t = T(:diamonds)
    t.add(p1, C(:diamonds, :nine))
    t.add(p2, C(:diamonds, :eight))
    assert_equal p1, t.winner[0]
    assert_equal C(:diamonds, :nine), t.winner[1]

    t = T(:diamonds)
    t.add(p1, C(:diamonds, :seven))
    t.add(p2, C(:diamonds, :eight))
    assert_equal p2, t.winner[0]
    assert_equal C(:diamonds, :eight), t.winner[1]

    t = T(:diamonds)
    t.add(p1, C(:diamonds, :six))
    t.add(p2, C(:diamonds, :seven))
    assert_equal p2, t.winner[0]
    assert_equal C(:diamonds, :seven), t.winner[1]

    t = T(:diamonds)
    t.add(p1, C(:diamonds, :four))
    t.add(p2, C(:diamonds, :six))
    assert_equal p2, t.winner[0]
    assert_equal C(:diamonds, :six), t.winner[1]

    t = T(:diamonds)
    t.add(p1, C(:diamonds, :three))
    t.add(p2, C(:diamonds, :four))
    assert_equal p2, t.winner[0]
    assert_equal C(:diamonds, :four), t.winner[1]

    t = T(:diamonds)
    t.add(p1, C(:diamonds, :two))
    t.add(p2, C(:diamonds, :three))
    assert_equal p2, t.winner[0]
    assert_equal C(:diamonds, :three), t.winner[1]

    t = T(:diamonds)
    t.add(p1, C(:diamonds, :two))
    t.add(p2, C(:hearts, :king))
    assert_equal p1, t.winner[0]
    assert_equal C(:diamonds, :two), t.winner[1]

    t = T(:diamonds)
    t.add(p1, C(:diamonds, :two))
    t.add(p2, C(:hearts, :five))
    assert_equal p1, t.winner[0]
    assert_equal C(:diamonds, :two), t.winner[1]

    t = T(:diamonds)
    t.add(p1, C(:diamonds, :two))
    t.add(p2, C(:clubs, :five))
    assert_equal p1, t.winner[0]
    assert_equal C(:diamonds, :two), t.winner[1]

    t = T(:diamonds)
    t.add(p1, C('2d'))
    t.add(p2, C('5s'))
    assert_equal p1, t.winner[0]
    assert_equal C('2d'), t.winner[1]

    t = T(:diamonds)
    t.add(p1, C('5s'))
    t.add(p2, C('4d'))
    assert_equal p2, t.winner[0]
    assert_equal C('4d'), t.winner[1]

    t = T(:diamonds)
    t.add(p1, C('5c'))
    t.add(p2, C('3d'))
    assert_equal p2, t.winner[0]
    assert_equal C('3d'), t.winner[1]

    t = T(:diamonds)
    t.add(p1, C('5c'))
    t.add(p2, C('3c'))
    assert_equal p2, t.winner[0]
    assert_equal C('3c'), t.winner[1]
  end

  def test_offsuite
    t = T(:hearts)
    t.add 1, C('Qc')
    t.add 2, C('Td')
    t.add 3, C('3d')
    t.add 4, C('Kd')
    assert_equal 1, t.winner[0]
    assert_equal C('Qc'), t.winner[1]
  end

  def test_trick_order
    t = T(:diamonds)
    t.add(1, C('5d'))
    t.add(2, C('jd'))
    t.add(3, C('ah'))
    t.add(4, C('ad'))
    assert_equal [1, C('5d')], t.plays[0]
    assert_equal [2, C('jd')], t.plays[1]
    assert_equal [3, C('ah')], t.plays[2]
    assert_equal [4, C('ad')], t.plays[3]
  end

  def test_player
    t = Object.new
    out = Player.new 'bob', nil
    out.team = t
    assert_equal t, out.team
    assert_equal 'bob', out.name
  end

  def test_score
    $team1 = Object.new
    def $team1.to_s 
      "bob is great, he give us"
    end
    $team2 = Object.new
    def $team2.to_s
      "the chocolate cake"
    end

    game = Object.new
    def game.teams
      [$team1, $team2]
    end
    
    out = Score.new game
    out.next_round
    out.add_score $team1, 15
    out.add_score $team2, 15
    assert_equal({$team1 => 15, $team2 => 15}, out.curr_total)
    out.next_round
    out.add_score $team1, 25
    out.add_score $team2, 5
    assert_equal({$team1 => 40, $team2 => 20}, out.curr_total)
    out.next_round
    out.add_score $team1, -15
    out.add_score $team2, 20
    assert_equal({$team1 => 25, $team2 => 40}, out.curr_total)
    out.next_round
    out.add_score $team1, -15
    out.add_score $team2, 30
    assert_equal({$team1 => 10, $team2 => 70}, out.curr_total)
    out.next_round
    out.add_score $team1, -15
    out.add_score $team2, 30
    assert_equal({$team1 => -5, $team2 => 100}, out.curr_total)
    out.next_round
    out.add_score $team1, -90
    out.add_score $team2, -90
    assert_equal({$team1 => -95, $team2 => 10}, out.curr_total)
    out.next_round
    out.add_score $team1, -90
    out.add_score $team2, -90
    assert_equal({$team1 => -185, $team2 => -80}, out.curr_total)
    out.next_round
    out.add_score $team1, -90
    out.add_score $team2, -90
    assert_equal({$team1 => -275, $team2 => -170}, out.curr_total)
    out.next_round
    out.add_score $team1, 90
    out.add_score $team2, 90
    assert_equal({$team1 => -185, $team2 => -80}, out.curr_total)
    out.next_round
    out.add_score $team1, 90
    out.add_score $team2, 90
    assert_equal({$team1 => -95, $team2 => 10}, out.curr_total)
    out.next_round
    out.add_score $team1, 90
    out.add_score $team2, 90
    assert_equal({$team1 => -5, $team2 => 100}, out.curr_total)
    out.next_round
    out.add_score $team1, 90
    out.add_score $team2, 90
    assert_equal({$team1 => 85, $team2 => 190}, out.curr_total)
    scard = <<END
 bob is great, he give us |    the chocolate cake    
-----------------------------------------------------
        15  -   15        |        15  -   15        
        25  -   40        |         5  -   20        
       (15) -   25        |        20  -   40        
       (15) -   10        |        30  -   70        
       (15) - (  5)       |        30  -  100        
       (90) - ( 95)       |       (90) -   10        
       (90) - (185)       |       (90) - ( 80)       
       (90) - (275)       |       (90) - (170)       
        90  - (185)       |        90  - ( 80)       
        90  - ( 95)       |        90  -   10        
        90  - (  5)       |        90  -  100        
        90  -   85        |        90  -  190        
END
  assert_equal(scard.strip, out.to_s.join("\n").strip)
  end

  def test_team
    player1 = Player.new 'player 1'
    player2 = Player.new 'player 2'
    player3 = Player.new 'player 3'
    team = Team.new player1, player2
    assert_equal 'player 1+player 2', team.to_s
    assert_equal team, player1.team
    assert_equal team, player2.team
    assert_equal nil, player3.team
    team.replace player1, player3
    assert_equal 'player 3+player 2', team.to_s
    assert_equal nil, player1.team
    assert_equal team, player2.team
    assert_equal team, player3.team
    team.replace player2, player1
    assert_equal 'player 3+player 1', team.to_s
    assert_equal team, player1.team
    assert_equal nil, player2.team
    assert_equal team, player3.team
  end

  def test_game_init
    out = Game.new :seat_count => 2
  end

  def test_kitty
    c = C(:spades, :jack)
    out = Kitty.new
    out.take c
    out.take c
    out.take c
    begin
      out.take c
      raise 'error should have been risen on to many kitty cards'
    rescue
    end
  end

  def test_ordered_players
    out = Game.new :seat_count => 4
    assert_equal 4, out.seats.size
    (0..3).each do |j|
      oplayers = out.ordered_players j
      assert_equal 4, oplayers.size
      (0..3).each do |i|
        assert_equal out.seats[(i+j)%4], oplayers[i]
      end
    end
  end

  def test_game_team
    game = Game.new :seat_count => 4, :team_size => 1
    assert_equal 4, game.teams.size
    game = Game.new :seat_count => 4, :team_size => 2
    assert_equal 2, game.teams.size
    game = Game.new :seat_count => 2, :team_size => 1
    assert_equal 2, game.teams.size
    game = Game.new :seat_count => 3, :team_size => 1
    assert_equal 3, game.teams.size
    game = Game.new :seat_count => 6, :team_size => 2
    assert_equal 3, game.teams.size
    game = Game.new :seat_count => 6, :team_size => 3
    assert_equal 2, game.teams.size
  end

  def test_next_dealer
    out = Game.new :seat_count => 4
    10.times do 
      dealer = out.next_dealer
      assert dealer
    end
    10.times do
      until out.seats.index(out.dealer) == 0
        dealer = out.next_dealer
      end
      assert out.dealer
    end
  end

  def test_bid
    out = Game.new :seat_count => 4
    out.seats.each do |p|
      def p.bid bid_history, possible_bids, dealer
        @bid
      end

      def p.bid= bid
        @bid = bid
      end

      p.bid = :pass
    end
    out.seats.first.bid = 15

    until out.seats.index(out.dealer) == 0
      out.next_dealer
    end
    dealer = out.dealer
    p, b, hist = out.get_bid 
    assert_equal dealer, p
    assert_equal 15, b
    assert_equal [
      {:player => out.seats[1], :bid => :pass},
      {:player => out.seats[2], :bid => :pass},
      {:player => out.seats[3], :bid => :pass},
      {:player => out.seats[0], :bid => 15}
    ], hist

    out.seats[1].bid = 15
    out.seats[2].bid = :pass
    out.seats[3].bid = 20
    out.seats[0].bid = :pass

    p, b, hist = out.get_bid 
    assert_equal out.seats[3], p
    assert_equal 20, b 
    assert_equal [
      {:player => out.seats[1], :bid => 15},
      {:player => out.seats[2], :bid => :pass},
      {:player => out.seats[3], :bid => 20},
      {:player => out.seats[0], :bid => :pass}
    ], hist

    out.seats[0].bid = 15
    out.seats[1].bid = 20
    out.seats[2].bid = 30
    out.seats[3].bid = :thirty_for_sixty

    until out.seats.index(out.dealer) == 3
      out.next_dealer
    end
    p, b, hist = out.get_bid 
    assert_equal out.seats[3], p
    assert_equal :thirty_for_sixty, b 
    assert_equal [
      {:player => out.seats[0], :bid => 15},
      {:player => out.seats[1], :bid => 20},
      {:player => out.seats[2], :bid => 30},
      {:player => out.seats[3], :bid => :thirty_for_sixty},
    ], hist
  end

  def test_game_deal
    players = (0..3).collect{|i| Player.new "pl #{i}", nil}
    game = Game.new :players => players, :seat_count => 4
    game.deal nil
    players.each do |p|
      assert_equal 5, p.hand.size
    end
    assert_equal 3, game.kitty.size
  end

  def test_game_over
    game = Game.new :seat_count => 4
    assert_nil game.game_over?
  end

  def test_card_compare
    c = C(:hearts, :ace)
    assert_equal :hearts, c.suite
    assert_equal -1, c.compare(C(:spades, :ace), :spades)
    assert_equal 1, c.compare(C(:spades, :jack), :spades)
    assert_equal -1, c.compare(C(:hearts, :eight))
    assert_equal -1, c.compare(C(:hearts, :eight), :spades)
    c = C(:hearts, :five)
    assert_equal -1, c.compare(C(:hearts, :jack), :hearts)
    assert_equal -1, c.compare(C(:hearts, :ten), :hearts)
    assert_equal -1, c.compare(C(:hearts, :eight), :hearts)
    assert_equal 1, c.compare(C(:hearts, :eight), :spades)
  end

  def test_player_output
    p = Player.new 'p1'
    assert_equal '<Player name: p1, team: nil, cards: []>', p.to_s
    p.take C('ah')
    assert_equal '<Player name: p1, team: nil, cards: [Ah]>', p.to_s
  end

  def test_valid_card
    g = Game.new :seat_count => 4
    h = [C('ah'), C('5d'), C('3s'), C('2c'), C('5c')]
    t = T(:hearts)
    v = g.valid_cards t, h
    assert_equal 5, v.size
    h.each do |c|
      assert v.include?c
    end
    t.add g.seats[0], C('5h')
    v = g.valid_cards t, h
    assert_equal 1, v.size
    assert_equal C('ah'), v.first

    # no trump
    h = [C('as'), C('2s'), C('3s'), C('4s'), C('5s')]
    v = g.valid_cards t, h
    assert_equal 5, v.size
  end

  def test_dumb_ass
    g = Game.new :seat_count => 4, :player_class => DumbAss
    g.deal nil
    p1 = g.seats[0]
    hand = p1.hand.clone
    t = Trick.new :hearts
    c = p1.play t
    assert hand.include?c
  end

  def test_rank
    assert_equal 0, C('5h').rank(:hearts)
    assert C('jc').rank(:hearts) > C('ks').rank(:hearts)
    assert C('ts').rank(:hearts) > C('kd').rank(:hearts)
  end

  def test_dumb_ass_discard
    da = DumbAss.new 'dumbass'
    da.take C('5h'), C('jh'), C('ah'), C('kh'), C('3d')
    discards = da.discard :hearts
    assert_equal 1, discards.size
    assert_equal C('3d'), discards.first
    assert_equal 4, da.hand.size
    assert da.hand.include?C('5h')
    assert da.hand.include?C('jh')
    assert da.hand.include?C('ah')
    assert da.hand.include?C('kh')

    da = DumbAss.new 'dumbass'
    da.take C('9h'), C('2d'), C('9c'), C('Jc'), C('5s')
    discards = da.discard :hearts
    assert_equal 4, discards.size
    assert discards.include?C('2d')
    assert discards.include?C('9c')
    assert discards.include?C('jc')
    assert discards.include?C('5s')
    assert_equal 1, da.hand.size
    assert_equal C('9h'), da.hand.first

    da = DumbAss.new 'dumbass'
    da.take C('9c'), C('2d'), C('9d'), C('Jc'), C('5s')
    discards = da.discard :hearts
    assert_equal 4, discards.size
    assert discards.include?C('2d')
    assert discards.include?C('9c')
    assert discards.include?C('9d')
    assert discards.include?C('5s')
    assert_equal 1, da.hand.size
    assert_equal C('jc'), da.hand.first

    da = DumbAss.new 'dumbass'
    da.take C('5c'), C('jc'), C('ah'), C('kc'), C('qc'), C('2c')
    discards = da.discard :clubs
    assert_equal 1, discards.size
    assert discards.include?C('2c')
    assert_equal 5, da.hand.size
    assert da.hand.include?C('5c')
    assert da.hand.include?C('jc')
    assert da.hand.include?C('ah')
    assert da.hand.include?C('kc')
    assert da.hand.include?C('qc')

    da = DumbAss.new 'dumbass'
    da.take C('8h'), C('jh'), C('6h'), C('7h'), C('4h'), C('5h')
    discards = da.discard :hearts
    assert_equal 1, discards.size
    assert discards.include?C('4h')
    assert_equal 5, da.hand.size
    assert da.hand.include?C('5h')
    assert da.hand.include?C('jh')
    assert da.hand.include?C('6h')
    assert da.hand.include?C('8h')
    assert da.hand.include?C('7h')
  end

  def test_events
  end
end
