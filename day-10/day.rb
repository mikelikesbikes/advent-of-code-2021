def run
  input = parse_input(read_input)

  # code to run part 1 and part 2
  puts syntax_error_score(input)
  puts autocomplete_score(input)
end

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
SYNTAX_ERROR_SCORES = { ")" => 3, "]" => 57, "}" => 1197, ">" => 25137 }.freeze
def syntax_error_score(lines)
  lines.sum do |line|
    autocomplete_line(line) and 0
  rescue => e
    SYNTAX_ERROR_SCORES[e.token]
  end
end


AUTOCOMPLETE_SCORES = { ")" => 1, "]" => 2, "}" => 3, ">" => 4 }.freeze
def score_completion(completion)
  completion.chars.reduce(0) { |acc, c| (acc * 5) + AUTOCOMPLETE_SCORES[c] }
end

def autocomplete_score(lines)
  lines
    .map { |l| autocomplete_line(l) rescue nil }
    .compact
    .map { |l| score_completion(l) }
    .sort
    .yield_self { |s| s[s.length / 2] }
end

class AutocompleteError < StandardError
  attr_reader :expected_token, :token
  def initialize(expected_token, token)
    @expected_token = expected_token
    @token = token
    super("Expected #{expected_token}, but found #{token} instead.")
  end
end

MATCHES = { "(" => ")", "[" => "]", "{" => "}", "<" => ">" }.freeze
def autocomplete_line(line)
  line = line.chars
  tokens = []
  while line.length > 0
    token = line.shift
    if MATCHES.key?(token)
      tokens.push(token)
    else
      expected_token = MATCHES[tokens.pop]
      raise AutocompleteError.new(expected_token, token) unless expected_token == token
    end
  end
  tokens.reverse.map { |t| MATCHES[t] }.join
end


### TESTS HERE ###
require "rspec"

describe "day" do
  let(:input) do
    parse_input(File.read("test.txt"))
  end

  let(:actual_input) do
    parse_input(File.read("input.txt"))
  end

  it "should solve part 1" do
    expect(syntax_error_score(input)).to eq 26397
    expect(syntax_error_score(actual_input)).to eq 411471
  end

  it "should find corrupted lines" do
    expect(input.select { |l| autocomplete_line(l) && false rescue true }).to eq (<<~TXT).split("\n")
      {([(<{}[<>[]}>{[]{[(<()>
      [[<[([]))<([[{}[[()]]]
      [{[{({}]{}}([{[{{{}}([]
      [<(<(<(<{}))><([]([]()
      <{([([[(<>()){}]>(<<{{
    TXT
  end

  it "should solve part 2" do
    expect(autocomplete_score(input)).to eq 288957
    expect(autocomplete_score(actual_input)).to eq 3122628974
  end

  it "should find incomplete lines" do
    expect(score_completion("}}]])})]")).to eq 288957
    expect(score_completion(")}>]})")).to eq 5566
    expect(score_completion("}}>}>))))")).to eq 1480781
    expect(score_completion("]]}}]}]}>")).to eq 995444
    expect(score_completion("])}>")).to eq 294
  end
end

run if $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?("ruby-memory-profiler")
