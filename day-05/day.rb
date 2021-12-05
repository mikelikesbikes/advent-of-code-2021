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
    Integer(line)
  end
end


### CODE HERE ###
class VentAnalyzer
  attr_reader :lines

  def self.from(str)
    lines = str.split("\n")
    new(lines.map { |l| Line.from(l) })
  end

  def initialize(lines)
    @lines = lines
  end

  def danger_count(include_diagonals: false)
    lines.each_with_object(Hash.new(0)) do |line, map|
      next unless include_diagonals || line.horizontal? || line.vertical?
      line.points.each do |p|
        map[p] += 1
      end
    end.count { |_, v| v > 1 }
  end
end

Point = Struct.new(:x, :y) do
  def plus(dx, dy)
    Point.new(self.x + dx, self.y + dy)
  end
end

class Line
  attr_reader :startpoint, :endpoint

  def self.from(str)
    startp, endp = str.split(" -> ")
    startpoint = Point.new(*startp.split(",").map(&:to_i))
    endpoint = Point.new(*endp.split(",").map(&:to_i))
    new(startpoint, endpoint)
  end

  def initialize(startpoint, endpoint)
    @startpoint = startpoint
    @endpoint = endpoint
  end

  def horizontal?
    startpoint.y == endpoint.y
  end

  def vertical?
    startpoint.x == endpoint.x
  end

  def points
    dx = endpoint.x <=> startpoint.x
    dy = endpoint.y <=> startpoint.y
    points = [startpoint]
    while points.last != endpoint
      points << points.last.plus(dx, dy)
    end
    points
  end
end

return unless $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?("ruby-memory-profiler")


### RUN STUFF HERE ###
analyzer = VentAnalyzer.from(read_input)
puts analyzer.danger_count
puts analyzer.danger_count(include_diagonals: true)
