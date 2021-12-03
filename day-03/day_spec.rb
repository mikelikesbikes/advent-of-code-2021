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
    expect(grate(input) * erate(input)).to eq 198
    expect(grate(actual_input) * erate(actual_input)).to eq 2583164
  end

  it "should calculate oxygen generator rating and co2 scrubber rating" do
    expect(orate(input)).to eq 23
    expect(co2srate(input)).to eq 10
    expect(orate(actual_input) * co2srate(actual_input)).to eq 2784375
  end
end
