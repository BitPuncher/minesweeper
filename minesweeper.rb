class Minesweeper
  attr_accessor :board


  class Board
    attr_accessor :tiles

    def initialize(size)
      # @tiles = Array.new(size) { Array.new(size, Tile.new) }
      @tiles = []
      size.times do |row|
        @tiles[row] = []
        size.times do |column|
          @tiles[row][column] << Tile.new(self, row, column)
        end
      end

    end

    def find_tile_neighbors(tile)

    end

  end

  class Tile
    attr_accessor :is_bomb, :value, :flagged, :board, :position

    def initialize(board, position)
      @is_bomb = false
      @value = 0
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



  end


end