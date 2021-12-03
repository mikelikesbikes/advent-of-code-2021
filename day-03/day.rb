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
    line.chars.map(&:to_i)
  end
end

### CODE HERE ###

def grate(input)
  first, *rest = input
  digits = first.zip(*rest)
  gamma = digits.map do |d|
    d.count(1) >= d.length/2 ? 1 : 0
  end
  gamma.join.to_i(2)
end

def erate(input)
  first, *rest = input
  digits = first.zip(*rest)
  gamma = digits.map do |d|
    d.count(1) < d.length/2 ? 1 : 0
  end
  gamma.join.to_i(2)
end

def orate(input)
  readings = input.dup
  i = 0
  while true
    d = readings.count { |digits| digits[i] == 1 } * 2 >= readings.length ? 1 : 0
    readings.select! { |digits| digits[i] == d }
    return readings.first.join.to_i(2) if readings.length == 1
    i += 1
  end
end

def co2srate(input)
  readings = input.dup
  i = 0
  while true
    d = readings.count { |digits| digits[i] == 0 } * 2 <= readings.length ? 0 : 1
    readings.select! { |digits| digits[i] == d }
    return readings.first.join.to_i(2) if readings.length == 1
    i += 1
  end
end

return unless $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?("ruby-memory-profiler")

input = parse_input(read_input)

### RUN STUFF HERE ###
puts grate(input) * erate(input)
puts orate(input) * co2srate(input)
