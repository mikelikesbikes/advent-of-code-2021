def read_input(filename = "input.txt")
  if !STDIN.tty?
    ARGF.read
  else
    filename = File.expand_path(ARGV[0] || filename, __dir__)
    File.read(filename)
  end
end

def parse_input(input)
  input.split(",").map(&:to_i).tally
end

### CODE HERE ###
def evolve(counts, n)
  n.times.reduce(counts) do |c, _|
    nc = Hash.new(0)
    c.each do |k, v|
      if k == 0
        nc[6] += v
        nc[8] += v
      else
        nc[k - 1] += v
      end
    end
    nc
  end.values.sum
end

return unless $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?("ruby-memory-profiler")

input = parse_input(read_input)

### RUN STUFF HERE ###
puts evolve(input, 80)
puts evolve(input, 256)
