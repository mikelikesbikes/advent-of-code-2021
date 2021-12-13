def run
  input = parse_input(read_input)

  # code to run part 1 and part 2
  puts count_paths(input, :no_repeats)
  puts count_paths(input, :one_repeat)
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
    map[c1.to_sym] << c2.to_sym
    map[c2.to_sym] << c1.to_sym
  end
end

CAN_VISIT = {
  no_repeats: ->(node, path) { !(node.match?(/[a-z]+/) && path.include?(node)) },
  one_repeat: ->(node, path) { !(node == :start || node.match?(/[a-z]+/) && path.has_repeat? && path.include?(node)) }
}

Path = Struct.new(:smalls, :path) do
  def self.build(path)
    new(Hash.new(0), []).tap do |p|
      path.each { |node| p.push(node) }
    end
  end

  def push(node)
    if node.match?(/[a-z]+/)
      smalls[node] += 1
    end
    path.push(node)
  end

  def pop
    last = path.pop
    smalls[last] -= 1
  end

  def has_repeat?
    smalls.each_value { |v| return true if v > 1 }
    false
  end

  def include?(node)
    path.include?(node)
  end

  def last
    path.last
  end
end

def count_paths(map, strategy, path = Path.build([:start]))
  return 1 if path.last == :end
  map[path.last]
    .sum do |node|
      if CAN_VISIT[strategy].call(node, path)
        path.push(node)
        count = count_paths(map, strategy, path)
        path.pop
        count
      else
        0
      end
    end
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
    expect(count_paths(input, :no_repeats)).to eq 10
    expect(count_paths(actual_input, :no_repeats)).to eq 4912
  end

  it "should solve part 2" do
    expect(count_paths(input, :one_repeat)).to eq 36
    expect(count_paths(actual_input, :one_repeat)).to eq 150004
  end
end

run if $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?("ruby-memory-profiler")
