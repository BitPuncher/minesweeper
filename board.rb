require './tile.rb'

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

    until mines_placed == @mines
      @tiles.each do |row|
        row.each do |tile|
          return if mines_placed == @mines #possibly refactor to get this out
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