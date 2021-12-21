def run
  input = parse_input(read_input)

  # code to run part 1 and part 2
  input.align
  puts input.beacons.length
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
  ScannerArray.from(input)
end

ScannerArray = Struct.new(:scanners) do
  def self.from(str)
    new(str.split("\n\n").map { |s| Scanner.from(s) })
  end

  def align(min_alignment = 12)
    first, *unaligned = scanners
    aligned = [first]
    while unaligned.length > 0
      next_scanner = unaligned.find do |s2|
        aligned.find do |a|
          a.align(s2, min_alignment)
        end
      end
      raise "no scanner to align" unless next_scanner
      unaligned.delete(next_scanner)
      aligned.push(next_scanner)
    end
  end
end

Scanner = Struct.new(:x, :y, :z, :beacons) do
  def initialize(x, y, z, beacons)
    super
    calc_distances
  end

  def distances
    @distances
  end

  def calc_distances
    @distances = {}
    (0..(beacons.length - 2)).each do |i|
      ((i + 1)..(beacons.length - 1)).each do |j|
        distance_vec = beacons[i].diff(beacons[j])
        @distances[distance_vec] = [beacons[i], beacons[j]]
      end
    end
  end

  def self.from(str)
    _, *beacons = str.split("\n")
    new(0, 0, 0, beacons.map { |s| Beacon.from(s) })
  end

  def align(other, min_alignment = 12)
    overlapping = self.distances.keys & other.distances.keys
    d0 = overlapping.flat_map { |k| other.distances[k] }.uniq.sort_by(&:to_a)
    d1 = overlapping.flat_map { |k| distances[k] }.uniq.sort_by(&:to_a)
    return nil unless d0.length >= min_alignment

    reorient(other)
    other.move(*d1.first.diff(d0.first))
    self
  end

  TRANSFORMS = [
    #face forward
    ->(x, y, z) { [ x,  y,  z] },
    ->(x, y, z) { [-y,  x,  z] },
    ->(x, y, z) { [-x, -y,  z] },
    ->(x, y, z) { [ y, -x,  z] },

    #face left
    ->(x, y, z) { [ z,  y, -x] },
    ->(x, y, z) { [ z,  x,  y] },
    ->(x, y, z) { [ z, -y,  x] },
    ->(x, y, z) { [ z, -x, -y] },

    #face back
    ->(x, y, z) { [-x,  y, -z] },
    ->(x, y, z) { [-y, -x, -z] },
    ->(x, y, z) { [ x, -y, -z] },
    ->(x, y, z) { [ y,  x, -z] },

    #face right
    ->(x, y, z) { [-z,  y,  x] },
    ->(x, y, z) { [-z,  x, -y] },
    ->(x, y, z) { [-z, -y, -x] },
    ->(x, y, z) { [-z, -x,  y] },

    #face up
    ->(x, y, z) { [ x,  z, -y] },
    ->(x, y, z) { [-y,  z, -x] },
    ->(x, y, z) { [-x,  z,  y] },
    ->(x, y, z) { [ y,  z,  x] },

    #face down
    ->(x, y, z) { [ x, -z,  y] },
    ->(x, y, z) { [ y, -z, -x] },
    ->(x, y, z) { [-x, -z, -y] },
    ->(x, y, z) { [-y, -z,  x] },
  ].freeze
  def reorient(other)
    # find overlapping beacons (by distance)

    # try orientations until overlapping beacons all have the same diff vector (not just absolute distance)
    txyz = other.beacons.first.to_a
    beacon = beacons.first

    transform = TRANSFORMS.map do |t|
      transformed_keys = distances.keys.map { |x,y,z| t.call(x, y, z) }
      overlapping_keys = (transformed_keys & other.distances.keys)
      [overlapping_keys.length, t]
    end.max_by { |a, _| a }

    #other.distances.keys.zip(distances.keys).each do |b0, b1|
    #  txyz = b0.to_a
    #  transforms = transforms.select do |t|
    #    t.call(b1.x, b1.y, b1.z) == txyz
    #  end
    #end

    beacons.each { |b| b.apply_transform(transform.last) }
    calc_distances
  end

  def offset_beacons(offset)
    beacons.map do |b|
      b.offset(*offset)
    end
  end

  def pos
    [x, y, z]
  end

  def move(x, y, z)
    self.x = x
    self.y = y
    self.z = z

  end
end

Beacon = Struct.new(:x, :y, :z) do
  def initialize(x = 0, y = 0, z = 0)
    super(x, y, z)
  end

  def self.from(str)
    new(*str.split(",").map(&:to_i))
  end

  def diff(other)
    [x - other.x, y - other.y, z - other.z]
  end

  def dist(other)
    diff(other).sum { |n| n.abs }
  end

  def offset(dx, dy, dz)
    Beacon.new(x + dx, y + dy, z + dz)
  end

  def apply_transform(fn)
    self.x, self.y, self.z = fn.call(x, y, z)
  end
end

### CODE HERE ###


### TESTS HERE ###
require "rspec"

describe "day 19" do
  let(:input) do
    parse_input(File.read("test.txt"))
  end

  let(:actual_input) do
    parse_input(File.read("input.txt"))
  end

  xit "should solve part 1" do
    input.align
    expect(input.beacons.length).to eq 79
  end

  it "should align sensors" do
    sa = parse_input(<<~TEXT)
      --- scanner 0 ---
      0,2
      4,1
      3,3

      --- scanner 1 ---
      -1,-1
      -5,0
      -2,1
    TEXT

    sa.align(3)
    expect(sa.scanners[0].pos).to eq [0, 0, 0]
    expect(sa.scanners[1].pos).to eq [5, 2, 0]
  end

  it "should re-orient sensors" do
    sa = parse_input(<<~TEXT)
      --- scanner 0 ---
      -1,-1,1
      -2,-2,2
      -3,-3,3
      -2,-3,1
      5,6,-4
      8,0,7

      --- scanner 0 ---
      1,-1,1
      2,-2,2
      3,-3,3
      2,-1,3
      -5,4,-6
      -8,-7,0

      --- scanner 0 ---
      -1,-1,-1
      -2,-2,-2
      -3,-3,-3
      -1,-3,-2
      4,6,5
      -7,0,8

      --- scanner 0 ---
      1,1,-1
      2,2,-2
      3,3,-3
      1,3,-2
      -4,-6,5
      7,0,8

      --- scanner 0 ---
      1,1,1
      2,2,2
      3,3,3
      3,1,2
      -6,-4,-5
      0,7,-8
    TEXT

    sa0, *rest = sa.scanners
    rest.each do |sa|
      sa.reorient(sa0)
      expect(sa.beacons).to eq sa0.beacons
    end

    sa0, sa1 = input.scanners
    sa1.reorient(sa0)
  end

  xit "should solve part 2" do
  end
end

run if $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?("ruby-memory-profiler")
