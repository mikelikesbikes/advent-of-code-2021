require "rspec"
require_relative "./day"

describe "day" do
  let(:input) do
    parse_input(File.read("test.txt"))
  end

  let(:actual_input) do
    parse_input(File.read("input.txt"))
  end

  it "should evolve the input n times" do
    expect(evolve(input, 18)).to eq 26
    expect(evolve(input, 80)).to eq 5934
    expect(evolve(input, 256)).to eq 26984457539

    expect(evolve(actual_input, 80)).to eq 362346
    expect(evolve(actual_input, 256)).to eq 1639643057051
  end
end
