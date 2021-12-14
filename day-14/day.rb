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
  template, rules = input.split("\n\n")
  rules = rules.split("\n").each_with_object({}) do |line, rules|
    pair, insert = line.split(" -> ")
    rules[pair] = pair.dup.insert(1, insert)
  end
  Polymer.new(template, rules)
end

Polymer = Struct.new(:template, :rules) do
  def expand
    i = template.length - 2
    while i >= 0
      s = template[i,2]
      if insert = rules[s]
        template.insert(i+1, insert)
      end
      i -= 1
    end
  end

  def expand
    self.template = expands(template)
  end

  def expands(s)
    return s if s.length == 1
    return rules[s] if rules[s]
    s1 = expands(s[0...s.length / 2])
    s2 = expands(s[s.length / 2..-1])

    rules[s] = s1[0..-2] + rules.fetch(s1[-1] + s2[0], "") + s2[1..-1]
  end

  def to_s
    template
  end

  def score
    min, max = template.each_char.each_with_object(Hash.new(0)) { |c, h| h[c] += 1 }.values.minmax
    max - min
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
    input.expand
    expect(input.to_s).to eq "NCNBCHB"

    input.expand
    expect(input.to_s).to eq "NBCCNBBBCBHCB"

    input.expand
    expect(input.to_s).to eq "NBBBCNCCNBBNBNBBCHBHHBCHB"

    input.expand
    expect(input.to_s).to eq "NBBNBNBBCCNBCNCCNBBNBBNBBBNBBNBBCBHCBHHNHCBBCBHCB"

    input.expand
    expect(input.to_s.length).to eq 97

    5.times { input.expand }
    expect(input.to_s.length).to eq 3073

    expect(input.score).to eq 1588
  end

  xit "should solve part 2" do
    40.times { input.expand }
    expect(input.score).to eq 2188189693529
  end
end

run if $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?("ruby-memory-profiler")
