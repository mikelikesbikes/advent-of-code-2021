def run
  input = parse_input(read_input)

  # code to run part 1 and part 2
  puts min_alignment_cost(input, :linear)
  puts min_alignment_cost(input, :triangular)
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
  input.split(",").map(&:to_i)
end

### CODE HERE ###
FUEL_STRATEGIES = {
  linear: ->(p, i) { (p - i).abs },
  triangular: ->(p, i) { n = (p - i).abs; n * (n + 1) / 2 }
}

def min_alignment_cost(positions, strategy)
  min, max = positions.minmax
  strategy = FUEL_STRATEGIES.fetch(strategy)
  (min..max).map do |i|
    positions.sum { |p| strategy.call(p, i) }
  end.min
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
    expect(min_alignment_cost(input, :linear)).to eq 37
    expect(min_alignment_cost(actual_input, :linear)).to eq 341558
  end

  it "should solve part 2" do
    expect(min_alignment_cost(input, :triangular)).to eq 168
    expect(min_alignment_cost(actual_input, :triangular)).to eq 93214037
  end
end

run if $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?("ruby-memory-profiler")
