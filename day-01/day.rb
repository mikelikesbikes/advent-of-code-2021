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

def count_increases(input)
  input.each_cons(2).count { |a, b| b > a }
end

def count_sliding_increases(input)
  count_increases(input.each_cons(3).map(&:sum))
end

return unless $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?("ruby-memory-profiler")

input = parse_input(read_input)

### RUN STUFF HERE ###
puts count_increases(input)
puts count_sliding_increases(input)
