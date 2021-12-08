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
  str.bytes.reduce(0) { |n, c| n | (1 << (c - 97)) }
end

def bit_count(n)
  i = 0
  count = 0
  while i < 7
    count += 1 if (n & 1) > 0
    n = n >> 1
    i += 1
  end
  count
end

def bit_diff(a, b)
  a & ~b
end

def delete_first(arr, &block)
  arr.delete_at(arr.index(&block))
end

Entry = Struct.new(:patterns, :output) do
  def self.from(str)
    patterns, outputs = str.split(" | ")
    new(patterns.split(" ").map { |s| to_num(s) },
        outputs.split(" ").map { |s| to_num(s) })
  end

  def decode
    lookup = Array.new(10)
    ps = patterns.dup
    lookup[1] = delete_first(ps) { |n| bit_count(n) == 2 }
    lookup[4] = delete_first(ps) { |n| bit_count(n) == 4 }
    lookup[7] = delete_first(ps) { |n| bit_count(n) == 3 }
    lookup[8] = delete_first(ps) { |n| bit_count(n) == 7 }
    lookup[6] = delete_first(ps) { |n| bit_count(n) == 6 && bit_count(bit_diff(n, lookup[1])) == 5 }
    lookup[0] = delete_first(ps) { |n| bit_count(n) == 6 && bit_count(bit_diff(n, lookup[4])) == 3 }
    lookup[9] = delete_first(ps) { |n| bit_count(n) == 6 }
    lookup[3] = delete_first(ps) { |n| bit_count(bit_diff(n, lookup[1])) == 3 }
    lookup[5] = delete_first(ps) { |n| bit_count(bit_diff(n, lookup[9])) == 0 }
    lookup[2] = ps.delete_at(0)

    output.reduce(0) { |acc, k| acc * 10 + lookup.index(k) }
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
