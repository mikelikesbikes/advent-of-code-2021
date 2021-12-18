require "json"

def run
  input = parse_input(read_input)

  # code to run part 1 and part 2
  res = input.reduce(&:+)
  puts res.magnitude

  max = [*0...input.length].permutation(2).map do |a, b|
    (input[a] + input[b]).magnitude
  end.max
  puts max
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
  input.split("\n").map do |line|
    Node(JSON.parse(line))
  end
end

PairNode = Struct.new(:left, :right) do

  def magnitude
    3 * left.magnitude + 2 * right.magnitude
  end

  def +(other)
    PairNode.new(self.dup, other.dup).tap { |node| node.reduce }
  end

  def explode(depth=0)
    return [self.left, self.right, Node(0)] if depth == 4

    if ((l, r, n) = left.explode(depth + 1))
      self.right.bubble_left(r) if ValueNode === r
      self.left = n
      return [l, nil, self]
    elsif ((l, r, n) = right.explode(depth + 1))
      self.left.bubble_right(l) if ValueNode === l
      self.right = n
      return [nil, r, self]
    end

    nil
  end

  def split
    if s = left.split
      self.left = s if ValueNode === self.left
      return s
    elsif s = right.split
      self.right = s if ValueNode === self.right
      return s
    end
    nil
  end

  def reduce
    #p self.to_a
    if explode
      #puts "exploded"
      reduce
    elsif split
      #puts "split"
      reduce
    end
  end

  def to_a
    [left.to_a, right.to_a]
  end

  def ==(other)
    other.class == self.class && other.to_a == self.to_a
  end

  def dup
    Node(to_a)
  end

  def bubble_left(v)
    left.bubble_left(v)
  end

  def bubble_right(v)
    right.bubble_right(v)
  end

  def inspect
    "#<PairNode #{self.to_a.inspect}>"
  end

  def to_s
    inspect
  end
end

ValueNode = Struct.new(:value) do
  def to_a
    value
  end

  def split
    return nil unless value > 9
    PairNode.new(ValueNode.new(value/2), ValueNode.new((value+1)/2))
  end

  def explode(d)
    nil
  end

  def bubble_right(v)
    self.value += v.value
  end

  def bubble_left(v)
    self.value += v.value
  end

  def magnitude
    value
  end
end

class Node
  def self.from(input)
    if Array === input
      raise ArgumentError, "exepected 2 elements got #{input.length}" unless input.length == 2
      PairNode.new(Node(input[0]), Node(input[1]))
    else
      ValueNode.new(input)
    end
  end end

def Node(input)
  Node.from(input)
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

  it "calculates magnitude" do
    expect(Node([9,1]).magnitude).to eq 29
    expect(Node([1,9]).magnitude).to eq 21
    expect(Node([[9,1], [1,9]]).magnitude).to eq 129
    expect(Node([[1,2],[[3,4],5]]).magnitude).to eq 143
    expect(Node([[[[0,7],4],[[7,8],[6,0]]],[8,1]]).magnitude).to eq 1384
    expect(Node([[[[1,1],[2,2]],[3,3]],[4,4]]).magnitude).to eq 445
    expect(Node([[[[3,0],[5,3]],[4,4]],[5,5]]).magnitude).to eq 791
    expect(Node([[[[5,0],[7,4]],[5,5]],[6,6]]).magnitude).to eq 1137
    expect(Node([[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]).magnitude).to eq 3488
  end

  it "adds pairs" do
    expect(Node([1, 0]) + (Node([0, 1]))).to eq Node([[1, 0], [0, 1]])
  end

  it "splits numbers" do
    expect(Node(10).split).to eq Node([5, 5])
    expect(Node(11).split).to eq Node([5, 6])
    expect(Node([1,1]).split).to eq nil
    n = Node([11,1])
    n.split
    expect(n).to eq Node([[5, 6], 1])
    n = Node([[[[0,7],4],[15,[0,13]]],[1,1]])
    n.split
    expect(n).to eq Node([[[[0,7],4],[[7,8],[0,13]]],[1,1]])
  end

  it "explodes pairs" do
    n = Node([1, 1])
    n.explode
    expect(n).to eq Node([1, 1])

    n = Node([[[[[9,8],1],2],3],4])
    n.explode
    expect(n).to eq Node([[[[0,9],2],3],4])

    n = Node([7,[6,[5,[4,[3,2]]]]])
    n.explode
    expect(n).to eq Node([7,[6,[5,[7,0]]]])

    n = Node([[6,[5,[4,[3,2]]]],1])
    n.explode
    expect(n).to eq Node([[6,[5,[7,0]]],3])

    n = Node([[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]])
    n.explode
    expect(n).to eq Node([[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]])

    n = Node([[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]])
    n.explode
    expect(n).to eq Node([[3,[2,[8,0]]],[9,[5,[7,0]]]])
  end

  it "reduces a pair" do
    n = Node([[[[4,3],4],4],[7,[[8,4],9]]]) + Node([1,1])
    n.reduce
    expect(n).to eq Node([[[[0,7],4],[[7,8],[6,0]]],[8,1]])
  end

  it "should solve part 1" do
    res = input.reduce(&:+)
    expect(res).to eq Node([[[[6,6],[7,6]],[[7,7],[7,0]]],[[[7,7],[7,7]],[[7,8],[9,9]]]])
    expect(res.magnitude).to eq 4140

    res = parse_input(<<~TEXT).reduce(&:+)
      [[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]
      [7,[[[3,7],[4,3]],[[6,3],[8,8]]]]
      [[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]
      [[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]
      [7,[5,[[3,8],[1,4]]]]
      [[2,[2,2]],[8,[8,1]]]
      [2,9]
      [1,[[[9,3],9],[[9,0],[0,7]]]]
      [[[5,[7,4]],7],1]
      [[[[4,2],2],6],[8,7]]
    TEXT
    expect(res).to eq Node([[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]])

    res = actual_input.reduce(&:+)
    expect(res.magnitude).to eq 3981
  end

  it "should solve part 2" do
    max = [*0...input.length].permutation(2).map do |a, b|
      (input[a] + input[b]).magnitude
    end.max
    expect(max).to eq 3993

    max = [*0...actual_input.length].permutation(2).map do |a, b|
      (actual_input[a] + actual_input[b]).magnitude
    end.max
    expect(max).to eq 4687
  end
end

run if $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?("ruby-memory-profiler")
