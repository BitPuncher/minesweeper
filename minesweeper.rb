require './tile.rb'
require './board.rb'
require 'yaml'

class Minesweeper
  INPUTS = {"S" :save_game, "F" :flag_tile, "E" :explore_tile}

  attr_accessor :board

  def initialize(size)
    @board = Board.new(size = 9)
  end

  def run
    # minesweeper = new_game_prompt
    # if minesweeper
    #   minesweeper.run
    #   return
    # end

    first_move = true
    game_over = false
    start_time = Time.now

    until game_over
      display_game_state

      input, argument = *get_input

      if first_move
        @board.generate_mines(position)
        first_move = false
      end

      input_result = send(input, argument)
      return if input == :save_game

      explored_mine = input_result

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

  def display_game_state
    puts @board
    puts "Flagged #{@board.count_is_flagged} out of #{@board.mines} mines"
  end

  def get_input
    print "Would you like to save or flag or explore a tile? [S, F, E] "
    input = gets.chomp.upcase

    argument = nil
    if input == "S"
      print "What name would you like to save under? "
      argument = gets.strip
    else
      print "Where would you like to do this? [row, column] "
      location = gets.split(",").map { |coordinate| coordinate.strip.to_i }
      argument = [location[0] - 1, location[1] - 1]
    end

    [INPUTS[input], argument]
  end

  def save_game(name)
    file = File.open("#{name}", "w")
    file.write(self.to_yaml)
    file.close
  end

  def flag_tile(position)
    @board.flag(position)
    false
  end

  def explore_tile(position)
    @board.explore(position)
  end
end

print "What size board would you like? [9. 16] "
size = gets.chomp.to_i
m = Minesweeper.new(size)
m.run