require 'cards/forte-fives'

names = %w{Bob Carrie Calvin Devyn}
players = (0..3).collect do |i|
  ForteFives::DumbAss.new names[i]
end

game = ForteFives::Game.new :seat_count => 4, :team_size => 1, :players => players
def game.event event, *args
  puts ":#{event}(#{args.join(', ')})"
end
until game.game_over?
  game.next_round
  puts '', game.score.to_s, ''
end

puts '', game.score.to_s
