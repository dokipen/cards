require 'war'
require 'pp'

print "Enter your name [Player 1]: "
name = gets.strip
name = "Player 1" if name.empty?
human = War::HumanPlayer.new name, $stdout, $stdin
g = War::Game.new human
game_over = false
rounds = 0
until game_over
  puts "-+"*40
  puts "You have #{g.player1.count} cards"
  r = g.play
  rounds += 1
  game_over = r[:game_over]
  puts "#{name}: #{r[name][:cards].join(', ')}"
  puts "#{g.player2.name}: #{r[g.player2.name][:cards].join(', ')}"
  if r[:winner] == name
    puts "You got it!"
  else
    puts "He got it."
  end
  if game_over
    puts "= Game Over ="
    puts "Winner: #{r[:winner]}"
    puts "#{rounds} rounds played."
  end
end
