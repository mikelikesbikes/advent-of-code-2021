def run
  input = parse_input(read_input)

  # code to run part 1 and part 2
  input.fold
  puts input.dot_count

  input.fold_all
  puts input
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
  dots, folds = input.split("\n\n")

  dots = dots.split("\n").each_with_object({}) do |line, dots|
    x, y = line.split(",")
    dots[[x.to_i, y.to_i]] = true
  end

  folds = folds.split("\n").map do |line|
    axis, n = line[11..].split("=")
    [axis, n.to_i]
  end

  Paper.new(dots, folds)
end

Paper = Struct.new(:dots, :folds) do
  def fold
    axis, n = folds.shift
    if axis == "x"
      fold_horizontal(n)
    else
      fold_vertical(n)
    end
  end

  def fold_all
    while folds.length > 0
      fold
    end
  end

  def fold_vertical(n)
    dots.select { |(x, y), v| y > n }.each do |(x, y), v|
      dots[[x, n - (y - n)]] = true
      dots.delete([x, y])
    end
  end

  def fold_horizontal(n)
    dots.select { |(x, y), v| x > n }.each do |(x, y), v|
      dots[[n - (x - n), y]] = true
      dots.delete([x, y])
    end
  end

  def dot_count
    dots.length
  end

  def to_s
    maxx = dots.map { |(x, y), _| x }.max
    maxy = dots.map { |(x, y), _| y }.max

    (0..maxy).map do |y|
      (0..maxx).map do |x|
        dots[[x, y]] ? "#" : "."
      end.join
    end.join("\n")
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
