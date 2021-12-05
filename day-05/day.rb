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
VentAnalyzer = Struct.new(:lines) do
  def self.from(str)
    new(str.split("\n").map { |l| Line.from(l) })
  end

  def danger_count(include_diagonals: false)
    lines
      .select { |line| include_diagonals || !line.diagonal? }
      .flat_map { |line| line.points.to_a }
      .tally
      .count { |_, v| v > 1 }
  end
end

Point = Struct.new(:x, :y) do
  def self.from(str)
    new(*str.split(",").map(&:to_i))
  end
end

Line = Struct.new(:startpoint, :endpoint) do
  def self.from(str)
    new(*str.split(" -> ").map { |s| Point.from(s) })
  end

  def diagonal?
    startpoint.x != endpoint.x && startpoint.y != endpoint.y
  end

  def points
    Enumerator.new do |yielder|
      dx = endpoint.x <=> startpoint.x
      dy = endpoint.y <=> startpoint.y
      p = startpoint
      loop do
        yielder << p
        break if p == endpoint
        p = Point.new(p.x + dx, p.y + dy)
      end
    end
  end
end

return unless $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?("ruby-memory-profiler")

### RUN STUFF HERE ###
analyzer = VentAnalyzer.from(read_input)
puts analyzer.danger_count
puts analyzer.danger_count(include_diagonals: true)
