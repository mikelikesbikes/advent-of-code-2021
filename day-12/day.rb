def run
  input = parse_input(read_input)

  # code to run part 1 and part 2
  puts count_paths(input)
  puts count_paths_2(input)
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
  input.split("\n").each_with_object(Hash.new { |h,k| h[k] = [] }) do |line, map|
    c1, c2 = line.split("-")
    map[c1] << c2
    map[c2] << c1
  end
end

### CODE HERE ###
def count_paths(map)
  finished_paths = []
  wip_paths = [["start"]]
  while wip_paths.length > 0
    path = wip_paths.shift
    map[path.last].each do |n|
      next if n.match?(/[a-z]+/) && path.include?(n)
      npath = path + [n]
      if n == "end"
        finished_paths << npath
      else
        wip_paths << npath
      end
    end
  end
  finished_paths.length
end

def count_paths_2(map)
  finished_paths = []
  wip_paths = [["start"]]
  while wip_paths.length > 0
    path = wip_paths.shift
    map[path.last].each do |n|
      next if n == "start" || n.match?(/[a-z]+/) && path.select { |n| n.match?(/[a-z]+/) }.tally.values.include?(2) && path.include?(n)
      npath = path + [n]
      if n == "end"
        finished_paths << npath
      else
        wip_paths << npath
      end
    end
  end
  finished_paths.length
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
    expect(count_paths(input)).to eq 10
    expect(count_paths(actual_input)).to eq 4912
  end

  it "should solve part 2" do
    expect(count_paths_2(input)).to eq 36
    expect(count_paths_2(actual_input)).to eq 150004
  end
end

run if $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?("ruby-memory-profiler")
