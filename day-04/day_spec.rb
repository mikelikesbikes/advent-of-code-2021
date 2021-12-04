require "rspec"
require_relative "./day"

describe "day" do
  let(:input) do
    File.read("test.txt")
  end

  let(:actual_input) do
    File.read("input.txt")
  end

  it "should ..." do
    bingo_analyzer = BingoAnalyzer.from(input)
    expect(bingo_analyzer.ideal_score).to eq 4512
  end

  it "should find the worst board" do
    bingo_analyzer = BingoAnalyzer.from(input)
    expect(bingo_analyzer.worst_score).to eq 1924
  end
end
