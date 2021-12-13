require "set"

def run
  paper = parse_input(read_input)

  # code to run part 1 and part 2
  paper.fold
  puts paper.dot_count

  paper.fold_all
  puts paper
end

def read_input(filename = "input.txt")
  if !STDIN.tty?
    ARGF.read
  else
    filename = File.expand_path(ARGV[0] || filename, __dir__)
    File.read(filename)
  end
end

def parse_input(input)
  Paper.from(input)
end

Point = Struct.new(:x, :y) do
  def fold(fold)
    case fold.axis
    when :x
      fold.n < x ? Point.new(2*fold.n - x, y) : self
    when :y
      fold.n < y ? Point.new(x, 2*fold.n - y) : self
    end
  end

  def self.from(str)
    new(*str.split(COMMA_STR).map!(&:to_i))
  end
end

Fold = Struct.new(:axis, :n) do
  def self.from(str)
    axis, n = str[11..].split(EQUAL_STR)
    new(axis.to_sym, n.to_i)
  end
end

Paper = Struct.new(:dots, :folds) do
  COMMA_STR = ",".freeze
  NEWL_STR = "\n".freeze
  BLANK_LINE_STR = "\n\n".freeze
  EQUAL_STR = "=".freeze
  EMPTY_STR = ".".freeze
  DOT_STR = "#".freeze
  def self.from(str)
    dots, folds = str.split(BLANK_LINE_STR)

    dots = dots.split(NEWL_STR).each_with_object(Set.new) do |line, dots|
      dots << Point.from(line)
    end

    folds = folds.split(NEWL_STR).map do |line|
      Fold.from(line)
    end

    Paper.new(dots, folds)
  end

  def fold
    fold = folds.shift
    dots
      .map { |dot| dot.fold(fold) }
      .each_with_object(dots.clear) { |dot| dots << dot }
  end

  def fold_all
    fold while folds.length > 0
  end

  def dot_count
    dots.length
  end

  def to_s
    maxx = maxy = 0
    dots.each do |p|
      maxx = p.x if p.x > maxx
      maxy = p.y if p.y > maxy
    end

    (0..maxy).map do |y|
      (0..maxx).map do |x|
        dots.member?(Point.new(x,y)) ? DOT_STR : EMPTY_STR
      end.join
    end.join(NEWL_STR)
  end
end

### CODE HERE ###


### TESTS HERE ###
require "rspec"

describe "day" do
  let(:input) do
    parse_input(File.read("test.txt"))
  end

  let(:actual_input) do
    parse_input(File.read("input.txt"))
  end

  it "should solve part 1" do
    input.fold
    expect(input.dot_count).to eq 17

    actual_input.fold
    expect(actual_input.dot_count).to eq 814
  end

  it "should solve part 2" do
    input.fold_all
    expect(input.to_s).to eq <<~TXT.chomp
      #####
      #...#
      #...#
      #...#
      #####
    TXT

    actual_input.fold_all
    expect(actual_input.to_s).to eq <<~TXT.chomp
      ###..####.####.#..#.###...##..####.###.
      #..#....#.#....#..#.#..#.#..#.#....#..#
      #..#...#..###..####.#..#.#..#.###..#..#
      ###...#...#....#..#.###..####.#....###.
      #....#....#....#..#.#.#..#..#.#....#.#.
      #....####.####.#..#.#..#.#..#.####.#..#
    TXT
  end
end

run if $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?("ruby-memory-profiler")
