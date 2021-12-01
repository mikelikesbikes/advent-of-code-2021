require "rspec"
require_relative "./day"

describe "day" do
  let(:input) do
    parse_input(<<~INPUT)
    INPUT HERE
    INPUT
  end

  let(:actual_input) do
    parse_input(File.read("input.txt"))
  end

  it "should ..." do
  end
end
