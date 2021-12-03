require "rspec"
require_relative "./day"

describe "day" do
  let(:input) do
    parse_input(<<~INPUT)
00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010
    INPUT
  end

  let(:actual_input) do
    parse_input(File.read("input.txt"))
  end

  it "should ..." do
    reporter = DiagnosticReporter.new(input)
    expect(reporter.gamma_rate * reporter.epsilon_rate).to eq 198

    reporter = DiagnosticReporter.new(actual_input)
    expect(reporter.gamma_rate * reporter.epsilon_rate).to eq 2583164
  end

  it "should calculate oxygen generator rating and co2 scrubber rating" do
    reporter = DiagnosticReporter.new(input)
    expect(reporter.oxygen_generator_rating * reporter.co2_scrubber_rating).to eq 230

    reporter = DiagnosticReporter.new(actual_input)
    expect(reporter.oxygen_generator_rating * reporter.co2_scrubber_rating).to eq 2784375
  end
end
