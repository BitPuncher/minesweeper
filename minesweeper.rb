require './tile.rb'
require './board.rb'

class Minesweeper
  attr_accessor :board, :size

  def initialize(size)
    @board = Board.new(size)
  end

  def run
    first_move = true
    game_over = false
    start_time = Time.now

    until game_over
      display_game_state

      flagging, position = *get_input

      if first_move
        @board.generate_mines(position)
        first_move = false
      end

      explored_mine = process_input(flagging, position)

      if explored_mine
        puts @board.render(true)
        print "Mine clicked! You lost"
        game_over = true
      end


      if @board.cleared?
        print "You won"
        game_over = true
      end
    end

    puts " in #{(Time.now - start_time).to_i} seconds"
  end

  def get_input
    print "Would you like to flag or explore a tile? [F, E] "
    flagging = gets.chomp.upcase == "F"
    print "Where would you like to do this? [row, column] "

    location = gets.chomp.split(",").map { |coordinate| coordinate.strip.to_i }
    tile_position = [location[0] - 1, location[1] - 1]
    [flagging, tile_position]
  end

  def display_game_state
    puts @board
    puts "Flagged #{@board.count_is_flagged} out of #{@board.mines} mines"
  end

  def process_input(flagging, position)
    if flagging
      @board.flag(position)
      return false
    else
      @board.explore(position)
    end
  end
end

print "What size board would you like? [9. 16] "
size = gets.chomp.to_i
m = Minesweeper.new(size)
m.run