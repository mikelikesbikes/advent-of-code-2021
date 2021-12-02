def read_input(filename = "input.txt")
  if !STDIN.tty?
    ARGF.read
  else
    filename = File.expand_path(ARGV[0] || filename, __dir__)
    File.read(filename)
  end
end

Position = Struct.new(:x, :depth) do
  def self.build
    new(0, 0)
  end

  def navigate(command)
    case command.dir
    when "forward"
      self.x += command.val
    when "up"
      self.depth -= command.val
    when "down"
      self.depth += command.val
    end
    self
  end
end

PositionWithAim = Struct.new(:x, :depth, :aim) do
  def self.build
    new(0, 0, 0)
  end

  def navigate(command)
    case command.dir
    when "forward"
      self.x += command.val
      self.depth += self.aim * command.val
    when "up"
      self.aim -= command.val
    when "down"
      self.aim += command.val
    end
    self
  end
end

Command = Struct.new(:dir, :val)
def parse_input(input)
  input.split("\n").map do |line|
    dir, val = line.split(" ")
    Command.new(dir, val.to_i)
  end
end

### CODE HERE ###
def navigate(commands, pos_class = Position)
  commands.reduce(pos_class.build) do |pos, command|
    pos.navigate(command)
  end
end

return unless $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?("ruby-memory-profiler")

input = parse_input(read_input)

### RUN STUFF HERE ###
pos = navigate(input, Position)
puts pos.x * pos.depth

pos = navigate(input, PositionWithAim)
puts pos.x * pos.depth
