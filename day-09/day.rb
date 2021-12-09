require 'set'

def run
  input = parse_input(read_input)

  # code to run part 1 and part 2
  puts risk_level(input)
  puts basin_score(input)
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
  input.split("\n").map { |l| l.chars.map(&:to_i) }
end

### CODE HERE ###
def risk_level(input)
  maxx = input.first.length - 1
  maxy = input.length - 1
  low_points = []
  input.each_with_index do |row, y|
    row.each_with_index do |cell, x|
      if adjacent(x, y, maxx, maxy).all? { |x2, y2| input[y2][x2] > cell }
        low_points << cell
      end
    end
  end
  low_points.sum { |x| x + 1 }
end

def find_basins(input)
  maxx = input.first.length - 1
  maxy = input.length - 1
  basin_index = 0
  adjacencies = {}
  input.each_with_index do |row, y|
    row.each_with_index do |cell, x|
      next if cell == 9
      adjacencies[[x, y]] = adjacent(x, y, maxx, maxy).reject { |x, y| input[y][x] == 9 }
    end
  end

  basins = []
  while adjacencies.length > 0
    basin = Set.new
    nextp = [adjacencies.first.first]
    while nextp.length > 0
      p = nextp.shift
      next if basin.member?(p)
      basin << p
      adjacents = adjacencies.delete(p)
      nextp.push(*adjacents)
    end
    basins << basin
  end
  basins
end

def basin_score(input)
  find_basins(input).map { |basin| basin.length }.sort.last(3).reduce(:*)
end

def adjacent(x, y, maxx, maxy)
  [[0, -1], [1, 0], [0, 1], [-1, 0]].map { |dx, dy| [x + dx, y + dy] }.select { |xx, yy| xx >= 0 && xx <= maxx && yy >= 0 && yy <= maxy }
end

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
    expect(risk_level(input)).to eq 15
  end

  it "should solve part 2" do
    expect(basin_score(input)).to eq 1134
  end
end

run if $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?("ruby-memory-profiler")
