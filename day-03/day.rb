def read_input(filename = "input.txt")
  if !STDIN.tty?
    ARGF.read
  else
    filename = File.expand_path(ARGV[0] || filename, __dir__)
    File.read(filename)
  end
end

def parse_input(input)
  input.split("\n")
end

### CODE HERE ###
class DiagnosticReporter
  attr_reader :readings, :width

  def initialize(readings)
    @width = readings.first.length
    @readings = readings.map { |s| s.to_i(2) }
  end

  def gamma_rate
    bit_positions.reduce(0) do |gamma, n|
      zeros, ones = count_ones_and_zeros(readings, n)
      unshift_bit(gamma, ones >= zeros ? 1 : 0)
    end
  end

  def epsilon_rate
    bit_positions.reduce(0) do |epsilon, n|
      zeros, ones = count_ones_and_zeros(readings, n)
      unshift_bit(epsilon, zeros >= ones ? 1 : 0)
    end
  end

  def oxygen_generator_rating
    bit_positions.reduce(readings) do |readings, n|
      zeros, ones = count_ones_and_zeros(readings, n)
      readings
        .select { |reading| nth_bit_eq?(reading, n, ones >= zeros ? 1 : 0) }
        .tap { |readings| return readings.first if readings.length == 1 }
    end
  end

  def co2_scrubber_rating
    bit_positions.reduce(readings) do |readings, n|
      zeros, ones = count_ones_and_zeros(readings, n)
      readings
        .select { |reading| nth_bit_eq?(reading, n, ones < zeros ? 1 : 0) }
        .tap { |readings| return readings.first if readings.length == 1 }
    end
  end

  private

  def bit_positions
    [*0...width].reverse.freeze
  end

  def count_ones_and_zeros(readings, n)
    readings.each_with_object([0, 0]) { |r, tally| tally[(r >> n) & 1] += 1 }
  end

  def nth_bit_eq?(reading, n, x)
    (reading >> n) & 1 == x
  end

  def unshift_bit(x, b)
    (x << 1) | b
  end
end


return unless $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?("ruby-memory-profiler")

input = parse_input(read_input)

### RUN STUFF HERE ###
reporter = DiagnosticReporter.new(input)
puts reporter.gamma_rate * reporter.epsilon_rate
puts reporter.oxygen_generator_rating * reporter.co2_scrubber_rating
