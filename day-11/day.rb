require "set"

def run
  input = parse_input(read_input)
  puts input.count_flashes(100)

  input = parse_input(read_input)
  puts input.flash_point
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
  OctopusGrid.from(input)
end

### CODE HERE ###
class OctopusGrid
  attr_reader :map
  def self.from(str)
    map = {}
    str.split("\n").each_with_index do |line, y|
      line.chars.each_with_index do |cell, x|
        map[[x,y]] = cell.to_i
      end
    end
    new(map)
  end

  def initialize(map)
    @map = map
  end

  def evolve
    map.each do |pos, energy|
      map[pos] = (energy + 1) % 10
    end

    flash_positions = map.keys.select { |k| map[k] == 0 }
    while flash_positions.length > 0
      fp = flash_positions.shift
      adjacent(fp).each do |pos|
        next if map[pos] == 0
        map[pos] = (map[pos] + 1) % 10
        flash_positions << pos if map[pos] == 0
      end
    end

    map.count { |_, v| v == 0 }
  end

  def to_s
    (0..9).map do |y|
      (0..9).map do |x|
        map[[x,y]]
      end.join
    end.join("\n")
  end

  def count_flashes(n)
    n.times.sum { evolve }
  end

  def flash_point
    i = 1
    while (n = evolve) != 100
      i += 1
    end
    i
  end

  DXDY = [-1, -1], [0, -1], [1, -1],
         [-1,  0],          [1,  0],
         [-1,  1], [0,  1], [1,  1]
  def adjacent((x, y))
    DXDY.map { |dx, dy| [x + dx, y + dy] }
      .select { |pos| map.key?(pos) }
  end
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
    expect(input.count_flashes(100)).to eq 1656
  end

  it "should solve part 2" do
    expect(input.flash_point).to eq 195
  end

  it "should evolve the grid in each step" do
    flashes = input.evolve
    expect(flashes).to eq 0
    expect(input.to_s).to eq <<~GRID.chomp
      6594254334
      3856965822
      6375667284
      7252447257
      7468496589
      5278635756
      3287952832
      7993992245
      5957959665
      6394862637
    GRID

    flashes = input.evolve
    expect(flashes).to eq 35
    expect(input.to_s).to eq <<~GRID.chomp
      8807476555
      5089087054
      8597889608
      8485769600
      8700908800
      6600088989
      6800005943
      0000007456
      9000000876
      8700006848
    GRID
  end
end

run if $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?("ruby-memory-profiler")
