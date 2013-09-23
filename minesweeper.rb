class Minesweeper
  attr_accessor :board, :size

  def initialize(size)
    @board = Board.new(size)
  end

  def run
    while true
      @board.display
    end
  end

  class Board
    attr_accessor :tiles, :size

    def initialize(size)
      @size = size
      @tiles = []
      @size.times do |row|
        @tiles[row] = []
        @size.times do |column|
          @tiles[row] << Tile.new(self, [row, column])
        end
      end
    end

    def find_tile_neighbors(tile)
      tile_neighbors = []

      neighbor_locations = [[-1, -1], [-1, 0], [-1, 1],
                            [0, -1],           [0, 1],
                            [1, -1], [1, 0], [1, 1]]
      neighbor_locations.each do |location|
        d_row = tile.position[0] + location[0]
        d_column = tile.position[1] + location[1]

        if is_on_board?([d_row, d_column])
          tile_neighbors << @board[d_row][d_column]
        end
      end

      tile_neighbors
    end

    def is_on_board?(position)
      valid_range = (0...@size)
      valid_range.include?(position[0]) && valid_range.include?(position[1])
    end

    def inspect
      column_axis = "  "
      @size.times do |row_number|
        column_axis << "#{row_number + 1} "
      end
      puts column_axis
      @tiles.each_with_index do |row, index|
        row_string = "#{index + 1} "
        @tiles[index].each { |tile| row_string << "#{tile.inspect} " }
        puts row_string
      end
    end
  end

  class Tile
    attr_accessor :is_bomb, :value, :flagged, :board, :position

    def initialize(board, position)
      @is_bomb = false
      @value = nil
      @flagged = false
      @board = board
      @position = position
    end

    def find_neighbors
      @board.find_tile_neighbors(self)
    end

    def change_bomb_state
      @is_bomb = !@is_bomb
    end

    def set_value
      neighbors = find_neighbors
      @value = neighbors.count { |tile| tile.is_bomb }
    end

    def inspect
      return "F" if @flagged
      case @value
      when nil then "*"
      when 0 then "_"
      else "#{value}"
      end
    end
  end
end

print "What size board would you like? [9. 16] "
size = gets.chomp.to_i
m = Minesweeper.new(size)