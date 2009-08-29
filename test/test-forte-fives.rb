require 'test/unit'
require 'cards/cards'
require 'cards/forte-fives'

class TestForteFivesTrick < Test::Unit::TestCase
  include PlayingCards
  include ForteFives

  def C(suite, val)
    Card.new(suite, val)
  end

  def T(suite)
    Trick.new(suite)
  end

  def test_diamonds_trump
    p1 = Object.new
    p2 = Object.new

    t = T(:diamonds)
    t.add(C(:diamonds, :five),  p1)
    t.add(C(:diamonds, :jack),  p2)
    assert_equal p1, t.winner
    assert_equal C(:diamonds, :five), t.winning_card

    t = T(:diamonds)
    t.add(C(:diamonds, :jack),  p1)
    t.add(C(:hearts, :ace),  p2)
    assert_equal p1, t.winner
    assert_equal C(:diamonds, :jack), t.winning_card

    t = T(:diamonds)
    t.add(C(:hearts, :ace),  p1)
    t.add(C(:diamonds, :ace),  p2)
    assert_equal p1, t.winner
    assert_equal C(:hearts, :ace), t.winning_card

    t = T(:diamonds)
    t.add(C(:diamonds, :ace),  p1)
    t.add(C(:diamonds, :king),  p2)
    assert_equal p1, t.winner
    assert_equal C(:diamonds, :ace), t.winning_card

    t = T(:diamonds)
    t.add(C(:diamonds, :king),  p1)
    t.add(C(:diamonds, :queen),  p2)
    assert_equal p1, t.winner
    assert_equal C(:diamonds, :king), t.winning_card

    t = T(:diamonds)
    t.add(C(:diamonds, :queen),  p1)
    t.add(C(:diamonds, :ten),  p2)
    assert_equal p1, t.winner
    assert_equal C(:diamonds, :queen), t.winning_card

    t = T(:diamonds)
    t.add(C(:diamonds, :ten),  p1)
    t.add(C(:diamonds, :nine),  p2)
    assert_equal p1, t.winner
    assert_equal C(:diamonds, :ten), t.winning_card

    t = T(:diamonds)
    t.add(C(:diamonds, :nine),  p1)
    t.add(C(:diamonds, :eight),  p2)
    assert_equal p1, t.winner
    assert_equal C(:diamonds, :nine), t.winning_card

    t = T(:diamonds)
    t.add(C(:diamonds, :seven),  p1)
    t.add(C(:diamonds, :eight),  p2)
    assert_equal p2, t.winner
    assert_equal C(:diamonds, :eight), t.winning_card

    t = T(:diamonds)
    t.add(C(:diamonds, :six),  p1)
    t.add(C(:diamonds, :seven),  p2)
    assert_equal p2, t.winner
    assert_equal C(:diamonds, :seven), t.winning_card

    t = T(:diamonds)
    t.add(C(:diamonds, :four),  p1)
    t.add(C(:diamonds, :six),  p2)
    assert_equal p2, t.winner
    assert_equal C(:diamonds, :six), t.winning_card

    t = T(:diamonds)
    t.add(C(:diamonds, :three),  p1)
    t.add(C(:diamonds, :four),  p2)
    assert_equal p2, t.winner
    assert_equal C(:diamonds, :four), t.winning_card

    t = T(:diamonds)
    t.add(C(:diamonds, :two),  p1)
    t.add(C(:diamonds, :three),  p2)
    assert_equal p2, t.winner
    assert_equal C(:diamonds, :three), t.winning_card

    t = T(:diamonds)
    t.add(C(:diamonds, :two),  p1)
    t.add(C(:hearts, :king),  p2)
    assert_equal p1, t.winner
    assert_equal C(:diamonds, :two), t.winning_card

    t = T(:diamonds)
    t.add(C(:diamonds, :two),  p1)
    t.add(C(:hearts, :five),  p2)
    assert_equal p1, t.winner
    assert_equal C(:diamonds, :two), t.winning_card

    t = T(:diamonds)
    t.add(C(:diamonds, :two),  p1)
    t.add(C(:clubs, :five),  p2)
    assert_equal p1, t.winner
    assert_equal C(:diamonds, :two), t.winning_card

    t = T(:diamonds)
    t.add(C(:diamonds, :two),  p1)
    t.add(C(:spades, :five),  p2)
    assert_equal p1, t.winner
    assert_equal C(:diamonds, :two), t.winning_card

    t = T(:diamonds)
    t.add(C(:spades, :five),  p1)
    t.add(C(:diamonds, :four),  p2)
    assert_equal p2, t.winner
    assert_equal C(:diamonds, :four), t.winning_card

    t = T(:diamonds)
    t.add(C(:clubs, :five),  p1)
    t.add(C(:diamonds, :three),  p2)
    assert_equal p2, t.winner
    assert_equal C(:diamonds, :three), t.winning_card

    t = T(:diamonds)
    t.add(C(:clubs, :five),  p1)
    t.add(C(:clubs, :three),  p2)
    assert_equal p2, t.winner
    assert_equal C(:clubs, :three), t.winning_card
  end

  def test_player
    t = Object.new
    out = Player.new 'bob'
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
    puts
    puts out.to_s
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
end
