def run
  input = parse_input(read_input)

  # code to run part 1 and part 2
  input.move_all
  puts input.step
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
  Seafloor.from(input)

end

Seafloor = Struct.new(:map, :step, :width, :height) do
  def self.from(str)
    lines = str.split("\n")

    map = {}
    lines.each_with_index do |line, y|
      line.chars.each_with_index do |c, x|
        c = c.to_sym
        if c == :> || c == :v
          map[[x, y]] = c
        end
      end
    end

    new(map, 0, lines.first.length, lines.length)
  end

  def move
    moved = false

    # > first
    new_map = {}
    map.each do |pos, c|
      x, y = pos
      next_pos = [(x + 1) % width, y]
      if c == :> && !map[next_pos]
        moved |= true
        new_map[next_pos] = c
      else
        new_map[pos] = c
      end
    end
    self.map = new_map

    # then v
    new_map = {}
    map.each do |pos, c|
      x, y = pos
      next_pos = [x, (y + 1) % height]
      if c == :v && !map[next_pos]
        moved |= true
        new_map[next_pos] = c
      else
        new_map[pos] = c
      end
    end
    self.map = new_map

    self.step += 1
    moved
  end

  def to_s
    (0...height).map do |y|
      (0...width).map do |x|
        map[[x, y]] || "."
      end.join
    end.join("\n")
  end

  def move_all
    true while move
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
    input.move
    expect(input.to_s).to eq <<~EXPECTED.chomp
      ....>.>v.>
      v.v>.>v.v.
      >v>>..>v..
      >>v>v>.>.v
      .>v.v...v.
      v>>.>vvv..
      ..v...>>..
      vv...>>vv.
      >.v.v..v.v
    EXPECTED
    9.times { input.move }
    expect(input.to_s).to eq <<~EXPECTED.chomp
      ..>..>>vv.
      v.....>>.v
      ..v.v>>>v>
      v>.>v.>>>.
      ..v>v.vv.v
      .v.>>>.v..
      v.v..>v>..
      ..v...>v.>
      .vv..v>vv.
    EXPECTED

    input.move_all
    expect(input.step).to eq 58
  end

  xit "should solve part 2" do
  end
end

run if $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?("ruby-memory-profiler")
