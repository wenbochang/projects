class Piece


  attr_accessor :color, :pos
  attr_writer :kinged

  def initialize(board, color, pos)
    @board = board
    @color = color
    @pos = pos
    @kinged = false
  end

  def perform_moves(move_seq)
    if self.valid_move_seq?(move_seq)
      self.perform_moves!(move_seq)
    else
      raise InvalidMoveError
    end
  end

  def perform_moves!(move_seq)
    if move_seq.length == 1
      move_pos = move_seq[0]
      valid = self.perform_slide(move_pos) || self.perform_jump(move_pos)
      raise InvalidMoveError unless valid
    else
      move_seq.each do |move_pos|
        raise InvalidMoveError unless self.perform_jump(move_pos)
      end
    end

  end

  def valid_move_seq?(move_seq)
    dup_board = @board.dup
    dup_piece = dup_board[@pos]
    begin
      dup_piece.perform_moves!(move_seq)
    rescue
      false
    else
      true
    end
  end

  #move directions for red/black
  SLIDE_DIRS = {
    :red => [ [1, 1], [1, -1] ],
    :black => [ [-1, 1], [-1, -1] ]
  }

  JUMP_DIRS = {
    :red => [ [2, 2], [2, -2] ],
    :black => [ [-2, 2], [-2, -2] ]
  }

  def move_dirs(dirs, color, pos)
    if self.kinged?
      move_dirs = dirs.values.flatten(1)
    else
      move_dirs = dirs[color]
    end

    move_dirs.map do |dirs_pos|
      [ dirs_pos[0] + @pos[0], dirs_pos[1] + @pos[1] ]
    end
  end

  def perform_slide(pos)
    valid = move_dirs(SLIDE_DIRS, @color, pos).include?(pos) &&
            @board.empty?(pos)
    return false unless valid

    self.move_piece_on_board(pos)
    true
  end

  def perform_jump(pos)
    valid = move_dirs(JUMP_DIRS, @color, pos).include?(pos) &&
            @board.enemy_between?(@pos, pos)
    return false unless valid


    self.remove_jumped_piece(pos)
    self.move_piece_on_board(pos)
    true
  end

  def maybe_promote(pos)
    king_row = { :red => 7, :black => 0 }

    if pos[0] == king_row[@color]
      @kinged = true
    end
  end

  def move_piece_on_board(pos)
    @board[@pos] = nil
    @pos = pos
    self.maybe_promote(pos)
    @board[pos] = self
  end

  def remove_jumped_piece(pos)
    jumped_piece = @board.get_between_piece(@pos, pos)
    @board[jumped_piece.pos] = nil
  end

  def kinged?
    @kinged
  end

  def render
    pawn_icon = { :red => "\u2659", :black => "\u265F"}
    king_icon = { :red => "\u2654", :black => "\u265A"}

    display = kinged? ? king_icon[@color] : pawn_icon[@color]
    "#{display} ".colorize(:blue)
  end

end