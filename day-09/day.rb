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
  map = {}
  input.split("\n").each_with_index { |l, y| l.chars.each_with_index { |c, x| map[[x, y]] = c.to_i } }
  map
end

### CODE HERE ###
def risk_level(input)
  find_low_points(input).sum { |_, v| v + 1 }
end

def find_low_points(input)
  input.select do |pos, cell|
    adjacent(input, pos).all? { |adj| cell < input[adj] }
  end
end

def find_basin(pos, input)
  basin = Set.new
  nextp = [pos]
  while nextp.length > 0
    p = nextp.shift
    next if basin.member?(p)
    basin << p
    nextp.push(*adjacent(input, p).reject { |p| input[p] == 9 })
  end
  basin
end

def basin_score(input)
  find_low_points(input).map { |pos, _| find_basin(pos, input).length }.sort.last(3).reduce(:*)
end

def adjacent(input, (x, y))
  [[0, -1], [1, 0], [0, 1], [-1, 0]].map { |dx, dy| [x + dx, y + dy] }.select { |pos| input[pos] }
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
