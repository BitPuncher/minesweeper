require './board.rb'

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