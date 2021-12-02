require "rspec"
require_relative "./day"

describe "day" do
  let(:input) do
    parse_input(<<~INPUT)
      forward 5
      down 5
      forward 8
      up 3
      down 8
      forward 2
    INPUT
  end

  let(:actual_input) do
    parse_input(File.read("input.txt"))
  end

  it "should navigate" do
    position = navigate(input)
    expect(position.x * position.depth).to eq 150

    position = navigate(actual_input)
    expect(position.x * position.depth).to eq 2120749
  end

  it "should navigate with aim" do
    position = navigate(input, PositionWithAim)
    expect(position.x * position.depth).to eq 900

    position = navigate(actual_input, PositionWithAim)
    expect(position.x * position.depth).to eq 2138382217
  end
end
