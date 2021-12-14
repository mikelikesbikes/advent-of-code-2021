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
  Polymer.from(input)
end

BLANK_LINE_STR = "\n\n"
NEWL_STR = "\n"
ARROW_STR = " -> "
Polymer = Struct.new(:pairs, :rules) do
  def self.from(str)
    template, rules = str.split(BLANK_LINE_STR)

    # delimit the string with a character so that we can track the last
    # character as the first character in the last pair
    pairs = (template + "☃").chars.each_cons(2).map(&:join).tally

    # generate the expansion rules, so that a given pair returns the 2 pairs it
    # expands to
    rules = rules
      .split(NEWL_STR)
      .each_with_object(Hash.new {|h, k| h[k] = [k]}) do |line, rules|
        pair, insert = line.split(ARROW_STR)
        rules[pair] = [pair[0] + insert, insert + pair[1]]
      end

    new(pairs, rules)
  end

  def expand
    new_pairs = Hash.new(0)
    pairs.each_pair do |k, v|
      rules[k].each do |pair|
        new_pairs[pair] += v
      end
    end
    self.pairs = new_pairs
  end

  def score
    pairs
      .each_with_object(Hash.new(0)) { |(k, v), tally| tally[k[0]] += v }
      .values
      .minmax
      .yield_self { |min, max| max - min }
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
