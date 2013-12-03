require_relative 'piece'
require 'colorize'

class Board

  attr_accessor :board

  def initialize
    make_empty_board
  end

  def [](pos)
    @board[pos[0]][pos[1]]
  end

  def []=(pos, piece)
    raise "not adding a piece" unless piece.nil? || piece.class == Piece
    @board[pos[0]][pos[1]] = piece
  end

  def make_empty_board
    @board = Array.new(8) { Array.new(8) {nil} }
  end

  def populate_board
    (0..2).each do |row_index|
      populate_row(row_index, :red)
    end

    (5..7).each do |row_index|
      populate_row(row_index, :black)
    end
  end

  def populate_row(row_index, color)
    i = row_index
    j = row_index % 2 == 0 ? 1 : 0
    4.times do
      @board[i][j] = Piece.new(self, color, [i,j])
      j += 2
    end
  end

  def empty?(pos)
    self[pos].nil?
  end

  def get_between_piece(self_pos, jump_pos)
    between_pos = [ (self_pos[0] + jump_pos[0]) / 2,
                   (self_pos[1] + jump_pos[1]) / 2 ]
    self[between_pos]
  end

  def enemy_between?(self_pos, jump_pos)
    between_piece = get_between_piece(self_pos, jump_pos)
    if between_piece.nil?
      false
    else
      self[self_pos].color != between_piece.color
    end
  end

  def tie?
    all_pieces.count == 2 &&
    all_pieces.first.color != all_pieces.last.color &&
    all_pieces.first.kinged? != all_pieces.last.kinged?
  end

  def win?(color)
    if color == :red
      all_pieces.select { |piece| piece.color == :black }.count == 0
    else
      all_pieces.select { |piece| piece.color == :red }.count == 0
    end
  end

  def all_pieces
    @board.flatten.compact
  end

  def dup
    dup_board = Board.new

    all_pieces.each do |piece|
      dup_piece = Piece.new(dup_board, piece.color, piece.pos.dup)
      dup_piece.kinged = piece.kinged?
      dup_board[piece.pos] = dup_piece
    end

    dup_board
  end

  def render
    display = "\n 0 1 2 3 4 5 6 7 \n"
    @board.each_with_index do |row, i|
      row.each_with_index do |piece, j|
        square = piece.nil? ? "  " : piece.render
        display += square.colorize(:background => (i + j) % 2 == 0 ? :light_white : :white)
      end
      display += "#{i}\n"
    end
    display
  end

end

