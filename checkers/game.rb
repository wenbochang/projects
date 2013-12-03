require_relative 'board'
require_relative 'errors'

class Game

  def initialize
    @board = Board.new
    #@board.populate_board
    self.manual_pop
    @current_turn = :red
    self.play
  end

  def manual_pop
    pos_arr = [[2, 4], [3, 5]]
    pos_arr.each { |pos| @board[pos] = Piece.new(@board, :red, pos) }
    pos_arr = [[5, 3], [5, 5], [6, 2]]
    pos_arr.each { |pos| @board[pos] = Piece.new(@board, :black, pos) }
  end

  def play
    until self.game_over?
      puts "\e[H\e[2J"
      puts @board.render

      self.ask_for_start_piece
      self.ask_for_move_seq
      puts "#{@current_turn} wins!" if @board.win?(@current_turn)

      self.switch_turns
    end


  end

  def ask_for_start_piece
    begin
      puts "#{@current_turn}'s turn to move"
      puts "Enter piece to move: "
      input = gets.chomp

      input_pos = parse_pos(input)
      @start_piece = @board[input_pos]

      raise NoPieceError if @start_piece.nil?
      raise WrongColorError unless @start_piece.color == @current_turn

    rescue InvalidInputError
      puts "invalid input"
      retry
    rescue NoPieceError
      puts "no piece there"
      retry
    rescue WrongColorError
      puts "chose wrong color"
      retry
    end
  end

  def ask_for_move_seq
    begin
      puts "Enter move sequence: "
      input = gets.chomp

      input_seq = parse_seq(input)
      @start_piece.perform_moves(input_seq)

    rescue InvalidInputError
      puts "invalid input"
      retry
    rescue InvalidMoveError
      puts "invalid move"
      retry
    end
  end

  def parse_pos(pos)
    #turns "21" into [2, 1]
    raise InvalidInputError if pos.length > 2 || pos.match(/[0-7][0-7]/).nil?

    if pos.include?(",")
      pos.gsub(" ", "").split(",").map { |n| n.to_i }
    else
      pos.split("").map { |n| n.to_i }
    end
  end

  def parse_seq(seq)
    #turns "21, 43" into [ [2, 1], [4, 3] ]
    if seq.include?(",")
      seq_split = seq.gsub(" ", "").split(",")
      seq_split.map { |pos| parse_pos(pos) }
    else
      [parse_pos(seq)]
    end
  end

  def game_over?
    @board.tie? || @board.win?(:red) || @board.win?(:black)
  end

  def switch_turns
    @current_turn = (@current_turn == :red ? :black : :red)
  end

end

game = Game.new