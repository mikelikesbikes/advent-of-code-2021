def run
  input = parse_input(read_input)

  # code to run part 1 and part 2
  input.enhance
  input.enhance
  puts input.count_pixels

  48.times { input.enhance }
  puts input.count_pixels
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
  Image.from(input)
end

Image = Struct.new(:pixels, :enhancements) do
  def initialize(*args)
    super
    @tracking_live_pixels = true
    @flip_flop_tracking = enhancements[0] == "#" && enhancements[511] == "."
  end

  def self.from(str)
    enhancements, pixel_str = str.split("\n\n")
    enhancements = enhancements.gsub(/\s+/, "")
    pixels = Hash.new(false)
    pixel_str.split("\n").each_with_index do |line, y|
      line.chars.each_with_index do |c, x|
        pixels[[x,y]] = true if c == "#"
      end
    end
    new(pixels, enhancements)
  end

  def enhance
    xrange, yrange = bounds
    default = @flip_flop_tracking && @tracking_live_pixels
    new_pixels = Hash.new(default)
    xrange.each do |x|
      yrange.each do |y|
        pixel = [x, y]
        if default != enhance_pixel(pixel)
          new_pixels[pixel] = !default
        end
      end
    end
    @tracking_live_pixels = !@tracking_live_pixels if @flip_flop_tracking
    self.pixels = new_pixels
  end

  def enhance_pixel((x, y))
    i = [
      [x - 1, y - 1], [x, y - 1], [x + 1, y - 1],
      [x - 1, y    ], [x, y    ], [x + 1, y    ],
      [x - 1, y + 1], [x, y + 1], [x + 1, y + 1]
    ].map { |p| pixels[p] ? 1 : 0 }.join.to_i(2)

    enhancements[i] == "#"
  end

  def self.from(str)
    enhancements, pixel_str = str.split("\n\n")
    enhancements = enhancements.gsub(/\s+/, "")
    pixels = {}
    pixel_str.split("\n").each_with_index do |line, y|
      line.chars.each_with_index do |c, x|
        if @flip_flop_tracking && !@tracking_live_pixels
          pixels[[x,y]] = true if c == "."
        else
          pixels[[x,y]] = true if c == "#"
        end
      end
    end
    new(pixels, enhancements)
  end

  def bounds
    minx, miny = pixels.keys.first
    maxx, maxy = pixels.keys.first
    pixels.each_key do |(x, y)|
      minx = x if x < minx
      maxx = x if x > maxx
      miny = y if y < miny
      maxy = y if y > maxy
    end
    [(minx - 1)..(maxx + 1), (miny - 1)..(maxy + 1)]
  end

  def count_pixels
    pixels.length
  end

  def to_s
    xrange, yrange = bounds
    yrange.map do |y|
      xrange.map do |x|
        pixels[[x, y]] ? "#" : "."
      end.join
    end.join("\n")
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
    input.enhance
    expect(input.count_pixels).to eq 24
    input.enhance
    expect(input.count_pixels).to eq 35
  end

  it "should solve part 2" do
    50.times { input.enhance }
    expect(input.count_pixels).to eq 3351
  end
end

run if $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?("ruby-memory-profiler")

# 5294 too low
# 5522 too high
