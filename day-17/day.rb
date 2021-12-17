require "set"

def run
  input = parse_input(read_input)

  # code to run part 1 and part 2
  puts input.max_y
  puts input.paths.length
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
  matches = input.match /x=(-?\d+)..(-?\d+), y=(-?\d+)..(-?\d+)/
  minx, maxx, miny, maxy = matches.captures.map(&:to_i)
  LaunchAnalyzer.new(minx..maxx, miny..maxy)
end

### CODE HERE ###
LaunchAnalyzer = Struct.new(:x_range, :y_range) do
  def max_y
    paths.max_by { |p| p.last }.last
  end

  def paths
    @paths ||= possible_xs.each_with_object(Set.new) do |x, paths|
      possible_ys.each do |y|
        m = max_y_for_path(x, y)
        if m
          paths << [x, y, m]
        end
      end
    end
  end

  def max_y_for_path(dx, dy)
    x, y = 0, 0
    maxy = 0
    while x <= x_range.end && y >= y_range.begin
      x += dx
      y += dy
      if y > maxy
        maxy = y
      end
      return maxy if x_range.include?(x) && y_range.include?(y)
      dx -= 1 if dx > 0
      dy -= 1
    end
    nil
  end

  private

  def possible_xs
    (0..(x_range.end))
  end

  def possible_ys
    ((y_range.end * 2)..(y_range.end.abs * 2))
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
    expect(input.max_y_for_path(7, 2)).to eq 3
    expect(input.max_y_for_path(6, 3)).to eq 6
    expect(input.max_y_for_path(9, 0)).to eq 0
    expect(input.max_y_for_path(6, 9)).to eq 45

    expect(input.max_y).to eq 45
  end

  it "should solve part 2" do
    expect(input.paths.length).to eq 112
  end

  it "does things" do
    paths = (<<~PATHS).split("\n").flat_map { |s| s.split(/\s+/) }.map { |p| p.split(",").map(&:to_i) }.to_set
      23,-10  25,-9   27,-5   29,-6   22,-6   21,-7   9,0     27,-7   24,-5
      25,-7   26,-6   25,-5   6,8     11,-2   20,-5   29,-10  6,3     28,-7
      8,0     30,-6   29,-8   20,-10  6,7     6,4     6,1     14,-4   21,-6
      26,-10  7,-1    7,7     8,-1    21,-9   6,2     20,-7   30,-10  14,-3
      20,-8   13,-2   7,3     28,-8   29,-9   15,-3   22,-5   26,-8   25,-8
      25,-6   15,-4   9,-2    15,-2   12,-2   28,-9   12,-3   24,-6   23,-7
      25,-10  7,8     11,-3   26,-7   7,1     23,-9   6,0     22,-10  27,-6
      8,1     22,-8   13,-4   7,6     28,-6   11,-4   12,-4   26,-9   7,4
      24,-10  23,-8   30,-8   7,0     9,-1    10,-1   26,-5   22,-9   6,5
      7,5     23,-6   28,-10  10,-2   11,-1   20,-9   14,-2   29,-7   13,-3
      23,-5   24,-8   27,-9   30,-7   28,-5   21,-10  7,9     6,6     21,-5
      27,-10  7,2     30,-9   21,-8   22,-7   24,-9   20,-6   6,9     29,-5
      8,-2    27,-8   30,-5   24,-7
    PATHS
    input_paths = input.paths.each_with_object(Set.new) { |(x, y, _), p| p << [x, y] }
    expect(input_paths).to eq paths
  end
end

run if $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?("ruby-memory-profiler")
