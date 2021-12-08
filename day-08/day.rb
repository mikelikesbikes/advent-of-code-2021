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

Entry = Struct.new(:patterns, :output) do
  def self.from(str)
    patterns, outputs = str.split(" | ")
    new(patterns.split(" ").map(&:chars).map(&:sort),
        outputs.split(" ").map(&:chars).map(&:sort))
  end

  def decode
    one = patterns.find { |p| p.length == 2 }
    four = patterns.find { |p| p.length == 4 }
    seven = patterns.find { |p| p.length == 3 }
    eight = patterns.find { |p| p.length == 7 }
    #
    # 6 digits
    # zero, six, nine
    six_digits = patterns.select { |p| p.length == 6 }
    six = six_digits.find { |six| (six - one).length == 5 }
    zero_nine = six_digits - [six]
    zero = zero_nine.find { |zero| (zero - four).length == 3 }
    nine = (zero_nine - [zero]).first

    # 5 digits
    # two, three, five
    five_digits = patterns.select { |p| p.length == 5 }
    three = five_digits.find { |three| (three - one).length == 3 }
    two_five = five_digits - [three]
    five = two_five.find { |five| (five - nine).length == 0 }
    two = (two_five - [five]).first

    lookup = {
      zero => "0",
      one => "1",
      two => "2",
      three => "3",
      four => "4",
      five => "5",
      six => "6",
      seven => "7",
      eight => "8",
      nine => "9"
    }

    output.map { |k| lookup[k] }.join.to_i
  end
end

### CODE HERE ###
def count_unique_numbers(lines)
  lines.sum do |line|
    line.output.count do |pattern|
      [2, 4, 3, 7].include?(pattern.length)
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
