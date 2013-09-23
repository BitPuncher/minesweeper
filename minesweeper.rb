class Minesweeper
  attr_accessor :board, :size

  def initialize(size)
    @board = Board.new(size)
  end

  def run
    first_move = true
    game_over = false
    until game_over
      puts @board
      puts "Flagged #{@board.count_is_flagged} out of #{@board.mines} mines"

      print "Would you like to flag or explore a tile? [F, E] "
      flagging = gets.chomp.upcase == "F"
      print "Where would you like to do this? [row, column] "
      location_input = gets.chomp

      location = location_input.split(",").map { |coordinate| coordinate.strip.to_i }
      tile_position = [location[0] - 1, location[1] - 1]

      if first_move
        @board.generate_mines(tile_position)
        first_move = false
      end

      if flagging
        @board.flag(tile_position)
      else
        explored_mine = @board.explore(tile_position)
        if explored_mine
          puts "Mine clicked! Game over"
          puts @board.render(true)
          game_over = true
        end
      end

      if @board.cleared?
        puts "You won"
        game_over = true
      end
    end
  end

  class Board
    attr_reader :tiles, :size, :mines

    def initialize(size)
      @size = size
      @tiles = []
      @size.times do |row|
        @tiles[row] = []
        @size.times do |column|
          @tiles[row] << Tile.new(self, [row, column])
        end
      end
      @mines = size == 9 ? 10 : 40
    end

    def find_tile_neighbors(position)
      tile_neighbors = []

      neighbor_locations = [[-1, -1], [-1, 0], [-1, 1],
                            [0, -1],           [0, 1],
                            [1, -1], [1, 0], [1, 1]]
      neighbor_locations.each do |location|
        d_row = position[0] + location[0]
        d_column = position[1] + location[1]

        if is_on_board?([d_row, d_column])
          tile_neighbors << @tiles[d_row][d_column]
        end
      end

      tile_neighbors
    end

    def is_on_board?(position)
      valid_range = (0...@size)
      valid_range.include?(position[0]) && valid_range.include?(position[1])
    end

    def flag(position)
      @tiles[position[0]][position[1]].change_flag
    end

    def explore(position)
      tile = @tiles[position[0]][position[1]]

      if tile.is_flagged
        puts "Tile is is_flagged, unflag to explore!"
        return
      end

      return true if tile.is_mine

      tile.calculate_value

      if tile.value == 0
        find_tile_neighbors(position).each do |neighbor_tile|
          explore(neighbor_tile.position) unless neighbor_tile.value
        end
      end

      false
    end

    def generate_mines(ignore_position)
     ignore_positions = [ignore_position]
      ignore_positions += find_tile_neighbors(ignore_position).map { |tile| tile.position }

      mines_placed = 0

      while true
        @tiles.each do |row|
          row.each do |tile|
            return if mines_placed == @mines
            next if tile.is_mine || ignore_positions.include?(tile.position)
            if rand(100) < 13
              tile.set_mine
              mines_placed += 1
            end
          end
        end
      end
    end

    def cleared?
      all_explored? || count_is_flagged == @mines
    end

    def all_explored?
      @tiles.each do |row|
        row.each do |tile|
          return false if !tile.is_mine && tile.value.nil?
        end
      end
      true
    end

    def count_is_flagged
      mines_is_flagged = 0
      @tiles.each do |row|
        row.each do |tile|
          mines_is_flagged += 1 if tile.is_mine && tile.is_flagged
        end
      end
      mines_is_flagged
    end

    def render(show_mines = false)
      result = ""
      column_axis = "  "
      @size.times do |row_number|
        column_axis << "#{row_number + 1} ".rjust(3)
      end
      result << column_axis + "\n"

      @tiles.each_with_index do |row, index|
        row_string = "#{index + 1} ".rjust(3)
        @tiles[index].each { |tile| row_string << "#{tile.render(show_mines)}  " }
        result << row_string + "\n"
      end

      result
    end

    def to_s
      render
    end
  end

  class Tile
    attr_reader :board, :position, :value, :is_mine
    attr_accessor :is_flagged

    def initialize(board, position)
      @is_mine = false
      @value = nil
      @is_flagged = false
      @board = board
      @position = position
    end

    def set_mine
      @is_mine = true
    end

    def change_flag
      @is_flagged = !@is_flagged
    end

    def calculate_value
      @value = @board.find_tile_neighbors(@position).count { |tile| tile.is_mine }
    end

    def render(show_mines = false)
      return "M" if show_mines && @is_mine
      return "F" if @is_flagged
      case @value
      when nil then "*"
      when 0 then "_"
      else "#{value}"
      end
    end

    def to_s
      render
    end
  end
end

print "What size board would you like? [9. 16] "
size = gets.chomp.to_i
m = Minesweeper.new(size)
m.run