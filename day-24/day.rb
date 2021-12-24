def run
  #puts Monad.digit_rules
  puts Monad.find_answers
end

def read_input(filename = "input.txt")
  if !STDIN.tty?
    ARGF.read
  else
    filename = File.expand_path(filename, __dir__)
    File.read(filename)
  end
end

def parse_input(input)
  ALU.from(input)
end

class ALU
  attr_reader :registers
  attr_reader :instructions

  def initialize(instructions)
    @instructions = instructions
    @registers = { w: 0, x: 0, y: 0, z: 0 }
  end

  def self.from(str)
    new(str.split("\n").map { |l| Instruction.from(l) })
  end

  Instruction = Struct.new(:op, :register, :val) do
    def self.from(str)
      op, register, val = str.split(" ")
      val = val.match?(/[wxyz]/) ? val.to_sym : val.to_i if val
      new(op.to_sym, register.to_sym, val)
    end
  end

  def run(input)
    input = input.split("\n").map(&:to_i) if String === input
    instructions.each do |ins|
      case ins.op
      when :inp
        registers[ins.register] = input.shift
      when :add
        b = Symbol === ins.val ? registers[ins.val] : ins.val
        registers[ins.register] += b
      when :mul
        b = Symbol === ins.val ? registers[ins.val] : ins.val
        registers[ins.register] *= b
      when :div
        b = Symbol === ins.val ? registers[ins.val] : ins.val
        registers[ins.register] /= b
      when :mod
        b = Symbol === ins.val ? registers[ins.val] : ins.val
        registers[ins.register] %= b
      when :eql
        b = Symbol === ins.val ? registers[ins.val] : ins.val
        registers[ins.register] = registers[ins.register] == b ? 1 : 0
      when :inspect
        p registers
      when :break
        require 'pry'; binding.pry
      end
    end
  end

  def reset
    registers.each_key { |k| registers[k] = 0 }
  end

  def register(n)
    registers[n]
  end
end

Monad = ALU.from(read_input("input.txt"))
def Monad.digit_rules
  rules = []
  stack = []
  instructions.each_slice(18).zip("A".."Z").each do |segment, id|
    divz = segment[4].val
    addx = segment[5].val
    addy = segment[15].val
    if divz == 1
      stack.push("#{id} + #{addy}")
    else
      rules << "#{id} = #{stack.pop} - #{-1 * addx}"
    end
  end
  rules
end

def Monad.find_answers
  stack = []
  first, last = 11111111111111, 99999999999999
  (0...14).each do |i|
    a = instructions[18*i + 5].val
    b = instructions[18*i + 15].val
    if a > 0
      stack << [i, b]
      next
    end

    j, b = stack.pop
    last -= ((a + b)*10**(13-(a > -b ? j : i))).abs
    first += ((a + b)*10**(13-(a < -b ? j : i))).abs
  end
  [first, last]
end

def Monad.valid_number?(n)
  input = n.digits.reverse
  self.run(input)
  registers[:z] == 0
end

### TESTS HERE ###
require "rspec"

describe "day" do
  it "should solve part 1" do
    expect(Monad.valid_number?(13579246899999)).to eq false
    expect(Monad.find_answers.last).to eq 94992992796199
  end

  it "should solve part 2" do
    expect(Monad.find_answers.first).to eq 11931881141161
  end

  describe "ALU" do
    it "multiplies" do
      alu = ALU.from(<<~TEXT)
        inp x
        mul x -1
      TEXT

      alu.run("12")
      expect(alu.register(:x)).to eq -12
    end

    it "eql things" do
      alu = ALU.from(<<~TEXT)
        inp z
        inp x
        mul z 3
        eql z x
      TEXT
      alu.run([3, 9])
      expect(alu.register(:z)).to eq 1

      alu.reset

      alu.run([3, 4])
      expect(alu.register(:z)).to eq 0
    end

    it "a bit reader" do
      alu = ALU.from(<<~TEXT)
        inp w
        add z w
        mod z 2
        div w 2
        add y w
        mod y 2
        div w 2
        add x w
        mod x 2
        div w 2
        mod w 2
      TEXT

      alu.run([10])
      expected = { w: 1, x: 0, y: 1, z: 0 }
      expect(alu.registers).to eq expected
    end
  end
end

run if $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?("ruby-memory-profiler")
