def run
  input = parse_input(read_input)

  # code to run part 1 and part 2
  input.boot
  puts input.on_in(Reactor::BOOT_REGION)
  puts input.on
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
  Reactor.from(input)
end

Box = Struct.new(:xrange, :yrange, :zrange) do
  def self.from(str)
    x1, x2, y1, y2, z1, z2 = str.scan(/-?\d+/).map(&:to_i)
    xs = x1 < x2 ? x1..x2 : x2..x1
    ys = y1 < y2 ? y1..y2 : y2..y1
    zs = z1 < z2 ? z1..z2 : z2..z1
    new(xs, ys, zs)
  end

  def volume
    xrange.size * yrange.size * zrange.size
  end

  def -(other)
    oxs = xrange & other.xrange
    return [self] if oxs.size == 0
    oys = yrange & other.yrange
    return [self] if oys.size == 0
    ozs = zrange & other.zrange
    return [self] if ozs.size == 0

    if oxs == self.xrange && oys == self.yrange && ozs == self.zrange
      []
    else
      [
        Box(xrange, yrange, zrange.begin..(ozs.begin - 1)),
        Box(xrange, yrange, (ozs.end + 1)..zrange.end),
        Box(xrange, yrange.begin..(oys.begin - 1), ozs),
        Box(xrange, (oys.end + 1)..yrange.end, ozs),
        Box(xrange.begin..(oxs.begin - 1), oys, ozs),
        Box((oxs.end + 1)..xrange.end, oys, ozs)
      ].select { |b| b.volume > 0 }
    end
  end
end

def Box(xs, ys, zs)
  Box.new(xs, ys, zs)
end

Reactor = Struct.new(:boot_instructions, :boxes) do
  def self.from(str)
    new(str.split("\n").map { |str| Instruction.from(str) }, [])
  end

  def boot
    self.boxes = boot_instructions.reduce([]) do |boxes, ins|
      boxes = boxes.flat_map { |c| c - ins.box }
      boxes << ins.box if ins.toggle
      boxes
    end
  end

  def on_in(box)
    offs = self.boxes.reduce([box]) do |boxes, cube|
      boxes.flat_map { |c| c - cube }
    end
    box.volume - offs.sum { |b| b.volume }
  end

  def on
    boxes.sum { |c| c.volume }
  end
end
Reactor::BOOT_REGION = Box(-50..50, -50..50, -50..50)

Instruction = Struct.new(:toggle, :box) do
  def self.from(str)
    toggle_str, ranges_str = str.split(" ")
    box = Box.from(ranges_str)
    new(toggle_str == "on", box)
  end
end

module RangeIntersection
  def &(other)
    b = self.begin < other.begin ? other.begin : self.begin
    e = self.end > other.end ? other.end : self.end
    (b..e)
  end
end
Range.prepend(RangeIntersection)


### TESTS HERE ###
require "rspec"

describe "day 22" do
  let(:simple_input) do
    parse_input(<<~TEXT)
      on x=10..12,y=10..12,z=10..12
      on x=11..13,y=11..13,z=11..13
      off x=9..11,y=9..11,z=9..11
      on x=10..10,y=10..10,z=10..10
    TEXT
  end

  let(:input) do
    parse_input(File.read("test.txt"))
  end

  let(:input2) do
    parse_input(File.read("test2.txt"))
  end

  let(:actual_input) do
    parse_input(File.read("input.txt"))
  end

  it "should solve part 1" do
    simple_input.boot
    expect(simple_input.on).to eq 39

    input.boot
    expect(input.on_in(Reactor::BOOT_REGION)).to eq 590784

    actual_input.boot
    expect(actual_input.on_in(Reactor::BOOT_REGION)).to eq 551693
  end

  it "should solve part 2" do
    input2.boot
    expect(input2.on).to eq 2758514936282235

    actual_input.boot
    expect(actual_input.on).to eq 1165737675582132
  end

  describe Box do
    describe "-" do
      it "for non overlapping boxes it returns the first box" do
        b1 = Box(0..10, 0..10, 0..10)
        b2 = Box(20..30, 20..30, 20..30)
        expect(b1 - b2).to eq [b1]
      end

      it "for fully overlapping boxes it returns empty" do
        b1 = Box(1..2, 1..2, 1..2)
        b2 = Box(0..5, 0..5, 0..5)
        expect(b1 - b2).to eq []
      end

      it "chops a box and returns the parts that aren't overlapping" do
        b1 = Box(0..5, 0..5, 0..5)
        b2 = Box(1..2, 1..2, 1..2)
        expect(b1 - b2).to eq [
          Box(0..5, 0..5, 0..0),
          Box(0..5, 0..5, 3..5),
          Box(0..5, 0..0, 1..2),
          Box(0..5, 3..5, 1..2),
          Box(0..0, 1..2, 1..2),
          Box(3..5, 1..2, 1..2)
        ]
      end

      it "chops out just a corner" do
        b1 = Box(0..5, 0..5, 0..5)
        b2 = Box(4..5, 4..5, 4..5)
        expect(b1 - b2).to eq [
          Box(0..5, 0..5, 0..3),
          Box(0..5, 0..3, 4..5),
          Box(0..3, 4..5, 4..5),
        ]
      end

      it "chops off a full full width rectangle from the bottom" do
        b1 = Box(0..5, 0..5, 0..5)
        b2 = Box(0..5, 4..5, 4..5)
        expect(b1 - b2).to eq [
          Box(0..5, 0..5, 0..3),
          Box(0..5, 0..3, 4..5),
        ]
      end

      it "chops off a full plane" do
        b1 = Box(0..5, 0..5, 0..5)
        b2 = Box(0..5, 0..5, 4..5)
        expect(b1 - b2).to eq [
          Box(0..5, 0..5, 0..3),
        ]
      end
    end
  end
end

run if $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?("ruby-memory-profiler")
