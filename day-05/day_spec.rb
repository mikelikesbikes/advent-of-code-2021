require "rspec"
require_relative "./day"

describe "day" do
  let(:input) do
    File.read("test.txt")
  end

  let(:actual_input) do
    File.read("input.txt")
  end

  it "calculates a simple danger count" do
    analyzer = VentAnalyzer.from(input)
    expect(analyzer.danger_count).to eq 5
    analyzer = VentAnalyzer.from(actual_input)
    expect(analyzer.danger_count).to eq 5608
  end

  it "should use diagonals too" do
    analyzer = VentAnalyzer.from(input)
    expect(analyzer.danger_count(include_diagonals: true)).to eq 12
    analyzer = VentAnalyzer.from(actual_input)
    expect(analyzer.danger_count(include_diagonals: true)).to eq 20299
  end
end
