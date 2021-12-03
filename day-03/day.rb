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
    line.to_i(2)
  end
end

### CODE HERE ###

def count_ones_and_zeros(readings, n)
  tally = readings.map { |r| (r >> n) & 1 }.tally
  [tally[0] || 0, tally[1] || 0]
end

def nth_bit_eq?(reading, n, x)
  (reading >> n) & 1 == x
end

def grate(input)
  width = input.max.to_s(2).length
  (1..width).reduce(0) do |gamma, n|
    zeros, ones = count_ones_and_zeros(input, width - n)
    ones >= zeros ? (gamma << 1) | 1 : gamma << 1
  end
end

def erate(input)
  width = input.max.to_s(2).length
  (1..width).reduce(0) do |gamma, n|
    zeros, ones = count_ones_and_zeros(input, width - n)
    zeros >= ones ? (gamma << 1) | 1 : gamma << 1
  end
end

def orate(input)
  width = input.max.to_s(2).length
  (1..width).each_with_object(input.dup) do |n, readings|
    zeros, ones = count_ones_and_zeros(readings, width - n)
    readings.select! do |reading|
      nth_bit_eq?(reading, width - n, ones >= zeros ? 1 : 0)
    end
    return readings.first if readings.length == 1
  end
end

def co2srate(input)
  width = input.max.to_s(2).length
  (1..width).each_with_object(input.dup) do |n, readings|
    zeros, ones = count_ones_and_zeros(readings, width - n)
    readings.select! do |reading|
      nth_bit_eq?(reading, width - n, ones < zeros ? 1 : 0)
    end
    return readings.first if readings.length == 1
  end
end

return unless $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?("ruby-memory-profiler")

input = parse_input(read_input)

### RUN STUFF HERE ###
puts grate(input) * erate(input)
puts orate(input) * co2srate(input)
