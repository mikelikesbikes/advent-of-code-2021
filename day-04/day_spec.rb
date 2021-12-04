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
    analyzer = BingoAnalyzer.from(input)
    expect(analyzer.best_score).to eq 4512

    analyzer = BingoAnalyzer.from(actual_input)
    expect(analyzer.best_score).to eq 58374
  end

  it "should find the worst board" do
    analyzer = BingoAnalyzer.from(input)
    expect(analyzer.worst_score).to eq 1924

    analyzer = BingoAnalyzer.from(actual_input)
    expect(analyzer.worst_score).to eq 11377
  end
end
