def run
  input = parse_input(read_input)

  puts evolve(input, 80)
  puts evolve(input, 256)
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
  input.split(",").map(&:to_i).tally
end

### CODE HERE ###
def evolve(counts, n)
  n.times.reduce(counts) do |c, _|
    nc = Hash.new(0)
    c.each do |k, v|
      if k == 0
        nc[6] += v
        nc[8] += v
      else
        nc[k - 1] += v
      end
    end
    nc
  end.values.sum
end

require "rspec"

describe "day" do
  let(:input) do
    parse_input(File.read("test.txt"))
  end

  let(:actual_input) do
    parse_input(File.read("input.txt"))
  end

  it "should evolve the input n times" do
    expect(evolve(input, 18)).to eq 26
    expect(evolve(input, 80)).to eq 5934
    expect(evolve(input, 256)).to eq 26984457539

    expect(evolve(actual_input, 80)).to eq 362346
    expect(evolve(actual_input, 256)).to eq 1639643057051
  end
end

run if $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?("ruby-memory-profiler")
