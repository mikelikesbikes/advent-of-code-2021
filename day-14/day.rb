def run
  input = parse_input(read_input)

  # code to run part 1 and part 2
  10.times { input.expand }
  puts input.score

  30.times { |i| puts 10 + i; input.expand }
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

Polymer = Struct.new(:pairs, :rules, :last_char) do
  def self.build(str)
    template, rules = str.split("\n\n")
    pairs = template.chars.each_cons(2).tally
    rules = rules.split("\n").each_with_object({}) do |line, rules|
      pair, insert = line.split(" -> ")
      rules[pair.chars] = insert
    end

    new(pairs, rules, template[-1])
  end

  def expand
    self.pairs = pairs.each_with_object(Hash.new(0)) do |(k, v), pairs|
      pairs[[k[0], rules[k]]] += v
      pairs[[rules[k], k[1]]] += v
    end
  end

  def score
    tally = pairs.each_with_object(Hash.new(0)) do |((c1, c2), v), tally|
      tally[c1] += v
    end
    tally[last_char] += 1
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
  end

  it "should solve part 2" do
    40.times { input.expand }
    expect(input.score).to eq 2188189693529
  end
end

run if $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?("ruby-memory-profiler")
