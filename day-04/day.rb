def read_input(filename = "input.txt")
  if !STDIN.tty?
    ARGF.read
  else
    filename = File.expand_path(ARGV[0] || filename, __dir__)
    File.read(filename)
  end
end

def parse_input(input)
  input = input.split("\n")
  numbers = input.shift.split(",").map(&:to_i)

  boards = []
  while input.length > 0
    input.shift
    boards << Board.from(input.shift(5))
  end

  BingoAnalyzer.new(numbers, boards)
end

class BingoAnalyzer
  attr_reader :numbers, :boards
  def initialize(numbers, boards)
    @numbers = numbers
    @boards = boards
  end

  def ideal_score
    numbers.each do |n|
      boards.each do |board|
        board.mark(n)
      end

      if board = boards.find { |b| b.winner? }
        return board.winning_score * n
      end
    end
  end

  def worst_score
    worst_board = nil
    numbers.each do |n|
      boards.each do |board|
        board.mark(n)
      end

      if boards.count { |b| !b.winner? } == 1
        worst_board = boards.find { |b| !b.winner? }
      end

      if boards.all? { |b| b.winner? }
        return worst_board.winning_score * n
      end
    end
  end
end

class Board
  def self.from(strs)
    new(strs.flat_map { |s| s.strip.split(/\s+/).map(&:to_i) })
  end

  attr_reader :squares, :marks
  def initialize(squares)
    raise "missing squares" unless squares.length == 25
    @squares = squares
    @marks = []
  end

  def mark(x)
    index = squares.index(x)
    marks << index if index
  end

  def winner?
    winning_score
  end

  SCORING_LINES = [
      [*0..4], [*5..9], [*10..14], [*15..19], [*20..24],
      [0, 5, 10, 15, 20],
      [1, 6, 11, 16, 21],
      [2, 7, 12, 17, 22],
      [3, 8, 13, 18, 23],
      [4, 9, 14, 19, 24],
    ]
  def winning_score
    return nil unless marks.length >= 5

    scoring_line = SCORING_LINES.find { |score_line| (marks & score_line).length == score_line.length }
    return nil unless scoring_line

    ([*0..24] - marks).map { |i| squares[i] }.sum
  end
end


### CODE HERE ###

return unless $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?("ruby-memory-profiler")

input = parse_input(read_input)

### RUN STUFF HERE ###
p input
puts input.ideal_score
puts input.worst_score
