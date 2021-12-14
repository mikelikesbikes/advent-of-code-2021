def run
  input = parse_input(read_input)

  # code to run part 1 and part 2
  10.times { input.expand }
  puts input.score

  30.times { |i| input.expand }
  puts input.score
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
  Polymer.build(input)
end

Polymer = Struct.new(:pairs, :rules) do
  def self.build(str)
    template, rules = str.split("\n\n")
    # delimit the string with a character so that we can track the last
    # character as the first character in the last pair
    pairs = (template + "-").chars.each_cons(2).tally
    rules = rules.split("\n").each_with_object({}) do |line, rules|
      pair, insert = line.split(" -> ")
      rules[pair.chars] = insert
    end
    new(pairs, rules)
  end

  def expand
    self.pairs = pairs.each_with_object(Hash.new(0)) do |(k, v), pairs|
      if ch = rules[k]
        pairs[[k[0], ch]] += v
        pairs[[ch, k[1]]] += v
      else
        pairs[k] += v
      end
    end
  end

  def score
    tally = pairs.each_with_object(Hash.new(0)) do |((c1, _), v), tally|
      tally[c1] += v
    end
    min, max = tally.values.minmax
    max - min
  end
end

require "rspec"

describe "day" do
  let(:input) do
    parse_input(File.read("test.txt"))
  end

  let(:actual_input) do
    parse_input(File.read("input.txt"))
  end

  it "should solve part 1" do
    10.times { input.expand }
    expect(input.score).to eq 1588

    10.times { actual_input.expand }
    expect(actual_input.score).to eq 2590
  end

  it "should solve part 2" do
    40.times { input.expand }
    expect(input.score).to eq 2188189693529

    40.times { actual_input.expand }
    expect(actual_input.score).to eq 2875665202438
  end
end

run if $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?("ruby-memory-profiler")
