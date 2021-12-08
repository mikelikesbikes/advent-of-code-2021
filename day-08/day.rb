def run
  input = parse_input(read_input)

  # code to run part 1 and part 2
  puts count_unique_numbers(input)
  puts sum_outputs(input)
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
  input.split("\n").map { |l| Entry.from(l) }
end

def to_num(str)
  str.chars.reduce(0) { |n, c| n | (1 << (c.ord - 97)) }
end

NSEGMENTS = 7
def bit_count(n)
  NSEGMENTS.times.count { ((n & 1) > 0).tap { n = n >> 1 } }
end

def bit_diff(a, b)
  a & ~b
end

Entry = Struct.new(:patterns, :output) do
  def self.from(str)
    patterns, outputs = str.split(" | ")
    new(patterns.split(" ").map { |s| to_num(s) },
        outputs.split(" ").map { |s| to_num(s) })
  end

  def decode
    lookup = {}
    lookup["1"] = patterns.find { |p| bit_count(p) == 2 }
    lookup["4"] = patterns.find { |p| bit_count(p) == 4 }
    lookup["7"] = patterns.find { |p| bit_count(p) == 3 }
    lookup["8"] = patterns.find { |p| bit_count(p) == 7 }

    # 6 digits
    # zero, six, nine
    six_digits = patterns.select { |p| bit_count(p) == 6 }
    lookup["6"] = six_digits.find { |six| bit_count(bit_diff(six, lookup["1"])) == 5 }
    six_digits.delete(lookup["6"])
    lookup["0"] = six_digits.find { |zero| bit_count(bit_diff(zero, lookup["4"])) == 3 }
    six_digits.delete(lookup["0"])
    lookup["9"] = six_digits.first

    # 5 digits
    # two, three, five
    five_digits = patterns.select { |p| bit_count(p) == 5 }
    lookup["3"] = five_digits.find { |three| bit_count(bit_diff(three, lookup["1"])) == 3 }
    five_digits.delete(lookup["3"])
    lookup["5"] = five_digits.find { |five| bit_count(bit_diff(five, lookup["9"])) == 0 }
    five_digits.delete(lookup["5"])
    lookup["2"] = five_digits.first

    lookup = lookup.invert

    output.map { |k| lookup[k] }.join.to_i
  end
end

### CODE HERE ###
def count_unique_numbers(lines)
  lines.sum do |line|
    line.output.count do |pattern|
      [2, 4, 3, 7].include?(bit_count(pattern))
    end
  end
end

def sum_outputs(lines)
  lines.sum { |l| l.decode }
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
    expect(count_unique_numbers(input)).to eq 26
  end

  it "should solve part 2" do
  end

  it "decodes a line" do
    line = parse_input(<<~TXT).first
      acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf
    TXT
    expect(line.decode).to eq 5353
    expect(input[0].decode).to eq 8394
    expect(input[4].decode).to eq 4873
    expect(sum_outputs(input)).to eq 61229
  end
end

run if $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?("ruby-memory-profiler")
