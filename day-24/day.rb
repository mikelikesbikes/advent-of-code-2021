def run
  input = parse_input(read_input)

  # code to run part 1 and part 2
  puts find_largest_model_num(input)
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

Monad = ALU.from(read_input)
def Monad.decompile
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
    expect(valid_model_num?(actual_input, 13579246899999)).to eq false
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

  xit "should solve part 2" do
  end
end

run if $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?("ruby-memory-profiler")
