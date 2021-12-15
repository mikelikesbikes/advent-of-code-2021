require "set"

def run
  input = parse_input(read_input)

  # code to run part 1 and part 2
  puts input.lowest_risk_path

  input.expand(5)
  puts input.lowest_risk_path
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
  input.split("\n").each_with_index do |line, y|
    line.chars.each_with_index do |r, x|
      map[[x,y]] = r.to_i
    end
  end
  ChitonAvoider.new(map)
end

ChitonAvoider = Struct.new(:map) do
  def lowest_risk_path
    end_point = map.keys.sort.last
    visited = Set.new([[0,0]])
    searches = [Search.new([[0,0]], 0)]
    lowest_risk_path = nil
    while searches.length > 0
      search = searches.shift
      return search.risk if search.last == end_point
      adjacents(search.last).each do |adj|
        next if visited.member?(adj)
        searches << search.next(adj, map[adj])
        visited << adj
      end
      searches.sort_by!(&:risk)
    end
  end

  DXDY = [[0, -1], [1, 0], [0, 1], [-1, 0]]
  def adjacents((x, y))
    DXDY.map { |dx, dy| [x + dx, y + dy] }.select { |pos| map[pos] }
  end

  Search = Struct.new(:path, :risk) do
    def next(node, risk)
      new_path = self.path.dup
      new_path << node

      Search.new(new_path, self.risk + risk)
    end

    def visited?(node)
      path.include?(node)
    end

    def last
      path.last
    end
  end

  def expand(n)
    new_map = {}
    maxx, maxy = map.keys.sort.last
    # expand in x direction
    map.each do |pos, v|
      x, y = pos
      n.times do |n|
        new_x = (maxx + 1) * n + x
        new_v = (v + n - 1) % 9 + 1
        new_map[[new_x, y]] = new_v
      end
    end


    # expand in y direction
    new_new_map = {}
    new_map.each do |pos, v|
      x, y = pos
      n.times do |n|
        new_y = (maxx + 1) * n + y
        new_v = (v + n - 1) % 9 + 1
        new_new_map[[x, new_y]] = new_v
      end
    end
    self.map = new_new_map
  end

  def map_string
    maxx, maxy = map.keys.sort.last
    (0..maxy).map do |y|
      (0..maxx).map do |x|
        map[[x,y]]
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

  let(:expanded) do
    File.read("expanded.txt").chomp
  end

  it "should solve part 1" do
    expect(input.lowest_risk_path).to eq 40
  end

  it "should solve part 2" do
    input.expand(5)
    expect(input.map_string).to eq expanded
    expect(input.lowest_risk_path).to eq 315
  end
end

run if $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?("ruby-memory-profiler")
