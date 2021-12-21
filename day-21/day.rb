def run
  input = parse_input(read_input)

  input.play
  puts input.roll * input.score.min

  input = parse_input(read_input)
  puts input.play_dirac.max
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

  Game.from(input)
end

### CODE HERE ###
Game = Struct.new(:positions, :score, :roll, :turn) do
  def self.from(str)
    positions = str.split("\n").map do |line|
      line[28..-1].to_i
    end
    new(positions, [0, 0], 0, 0)
  end

  def move
    if turn.even?
      # move player 1
      advance = (roll_dice + roll_dice + roll_dice) % 10
      new_pos = positions[0] + advance
      new_pos -= 10 if new_pos > 10
      positions[0] = new_pos
      score[0] += new_pos
    else
      # move player 2
      advance = (roll_dice + roll_dice + roll_dice) % 10
      new_pos = positions[1] + advance
      new_pos -= 10 if new_pos > 10
      positions[1] = new_pos
      score[1] += new_pos
    end
    self.turn += 1
  end

  def play
    move while score[0] < 1000 && score[1] < 1000
  end

  DIRAC = (1..3).each_with_object([]) { |i, p| (1..3).each { |j| (1..3).each { |k| p << i + j + k }}}.tally
  def play_dirac
    universes = { [positions[0], score[0], positions[1], score[1]] => 1 }
    wins = [0, 0]
    while universes.length > 0
      new_universes = Hash.new(0)
      universes.each do |(p1, score1, p2, score2), count|
        DIRAC.each do |roll1, roll1_count|
          new_p1 = (p1 + roll1 - 1) % 10 + 1
          s1 = score1 + new_p1
          if s1 >= 21
            wins[0] += (count * roll1_count)
            next
          end

          DIRAC.each do |roll2, roll2_count|
            new_p2 = (p2 + roll2 - 1) % 10 + 1
            s2 = score2 + new_p2
            if s2 >= 21
              wins[1] += (count * roll1_count * roll2_count)
              next
            end

            # if both player 1's roll and player 2's roll didn't end the game
            # then propogate forward universes matcing the count we started
            # with times the number of times the dirac rolls the given roll
            new_universes[[new_p1, s1, new_p2, s2]] += count * roll1_count * roll2_count
          end
        end
      end
      universes = new_universes
    end
    wins
  end

  def roll_dice
    roll = (self.roll % 100) + 1
    self.roll += 1
    roll
  end
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
    expect(input.score).to eq [0, 0]
    input.move
    expect(input.score).to eq [10, 0]
    input.move
    expect(input.score).to eq [10, 3]
    input.move
    expect(input.score).to eq [14, 3]
    input.move
    expect(input.score).to eq [14, 9]
    input.move
    expect(input.score).to eq [20, 9]
    input.move
    expect(input.score).to eq [20, 16]
    input.move
    expect(input.score).to eq [26, 16]
    input.move
    expect(input.score).to eq [26, 22]
    input.play
    expect(input.score).to eq [1000, 745]
    expect(input.roll * input.score.min).to eq 739785

    actual_input.play
    expect(actual_input.roll * actual_input.score.min).to eq 802452
  end

  it "should solve part 2" do
    expect(input.play_dirac).to eq [444356092776315, 341960390180808]
    expect(actual_input.play_dirac.max).to eq 270005289024391
  end
end

run if $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?("ruby-memory-profiler")
