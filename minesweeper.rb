require './tile.rb'
require './board.rb'
require 'yaml'

class Minesweeper
  INPUTS = {"S" => :save_game, "F" => :flag_tile, "E" => :explore_tile}

  attr_accessor :board, :elapsed_time

  def initialize
    @elapsed_time = 0
    @board = nil
  end

  def run
    first_move = true
    game_over = false

    load_file_name = load_game_prompt
    if load_file_name
      minesweeper = load_game(load_file_name)
      @board = minesweeper.board
      @elapsed_time = minesweeper.elapsed_time
      first_move = false
    else
      @board = Board.new(new_game_prompt)
    end

    @start_time = Time.now

    until game_over
      display_game_state

      input, argument = *get_input

      if first_move && input != :save_game
        @board.generate_mines(argument)
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

    puts " in #{@elapsed_time + (Time.now - @start_time).to_i} seconds"
  end

  def new_game_prompt
    print "How big of a board would you like? [9, 16] "
    gets.strip.to_i
  end

  def load_game_prompt
    print "Welcome to Minesweeper! Would you like to load a game? [y/n] "
    input = gets.strip.upcase

    if input == "Y"
      print "What is the save file name? "
      return gets.strip.downcase
    end

    nil
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
    @elapsed_time = Time.now - @start_time
    file = File.open("#{name}", "w")
    file.write(self.to_yaml)
    file.close
  end

  def load_game(file_name)
    YAML::load(File.read("./#{file_name}"))
  end

  def flag_tile(position)
    @board.flag(position)
    false
  end

  def explore_tile(position)
    @board.explore(position)
  end
end

Minesweeper.new.run