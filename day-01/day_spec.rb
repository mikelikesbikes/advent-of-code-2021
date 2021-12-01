require "rspec"
require_relative "./day"

describe "day" do
  let(:input) do
    parse_input(<<~INPUT)
      199
      200
      208
      210
      200
      207
      240
      269
      260
      263
    INPUT
  end

  let(:actual_input) do
    parse_input(File.read("input.txt"))
  end

  it "should count increases" do
    expect(count_increases(input)).to eq 7
  end

  it "should count increases in a sliding window" do
    expect(count_sliding_increases(input)).to eq 5
  end
end
