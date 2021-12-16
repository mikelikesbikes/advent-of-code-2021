# frozen_string_literal: true

def run
  packet = parse_input(read_input)

  # code to run part 1 and part 2
  puts packet.version_sum
  puts packet.value
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
  Packet.from([input].pack("H*").unpack("B*").first)
end

ValuePacket = Struct.new(:version, :type_id, :value) do
  def self.from(input)
    version = input.slice!(0,3).to_i(2)
    type_id = input.slice!(0,3).to_i(2)

    value = ""
    begin
      i = input.slice!(0,1).to_i
      bits = input.slice!(0,4)
      value += bits
    end while i == 1
    value = value.to_i(2)

    new(version, type_id, value)
  end

  def version_sum
    version
  end
end

OperatorPacket = Struct.new(:version, :type_id, :packets) do
  def self.from(input)
    version = input.slice!(0,3).to_i(2)
    type_id = input.slice!(0,3).to_i(2)

    packets = []
    length_type_id = input.slice!(0,1).to_i(2)
    case length_type_id
    when 0
      subpacket_length = input.slice!(0, 15).to_i(2)
      subpacket_input = input.slice!(0, subpacket_length)
      while subpacket_input.length > 0
        packets << Packet.from(subpacket_input)
      end
    when 1
      subpacket_count = input.slice!(0, 11).to_i(2)
      subpacket_count.times do
        packets << Packet.from(input)
      end
    end
    new(version, type_id, packets)
  end

  def version_sum
    version + packets.sum(&:version_sum)
  end
end

class SumPacket < OperatorPacket
  def value; packets.map(&:value).sum; end
end

class ProductPacket < OperatorPacket
  def value; packets.map(&:value).reduce(1, &:*); end
end

class MinPacket < OperatorPacket
  def value; packets.map(&:value).min; end
end

class MaxPacket < OperatorPacket
  def value; packets.map(&:value).max; end
end

class GreaterThanPacket < OperatorPacket
  def value; packets[0].value > packets[1].value ? 1 : 0; end
end

class LessThanPacket < OperatorPacket
  def value; packets[0].value < packets[1].value ? 1 : 0; end
end

class EqualPacket < OperatorPacket
  def value; packets[0].value == packets[1].value ? 1 : 0; end
end

class Packet
  def self.from(input)
    case input[3,3].to_i(2)
    when 0 then SumPacket.from(input)
    when 1 then ProductPacket.from(input)
    when 2 then MinPacket.from(input)
    when 3 then MaxPacket.from(input)
    when 4 then ValuePacket.from(input)
    when 5 then GreaterThanPacket.from(input)
    when 6 then LessThanPacket.from(input)
    when 7 then EqualPacket.from(input)
    end
  end
end

### TESTS HERE ###
require "rspec"

describe "day" do
  let(:actual_input) do
    parse_input(File.read("input.txt"))
  end

  it "should solve part 1" do
    expect(parse_input("8A004A801A8002F478").version_sum).to eq 16
    expect(parse_input("620080001611562C8802118E34").version_sum).to eq 12
    expect(parse_input("C0015000016115A2E0802F182340").version_sum).to eq 23
    expect(parse_input("A0016C880162017C3686B18A3D4780").version_sum).to eq 31
    expect(actual_input.version_sum).to eq 1002
  end

  it "parses value literal packets" do
    input = "110100101111111000101000".dup
    packet = Packet.from(input)
    expect(packet.version).to eq 6
    expect(packet.type_id).to eq 4
    expect(packet.value).to eq 2021
    expect(input.length).to eq 3
  end

  it "parses operator packets" do
    input = "00111000000000000110111101000101001010010001001000000000".dup
    packet = Packet.from(input)
    expect(packet.version).to eq 1
    expect(packet.type_id).to eq 6
    expect(packet.packets.length).to eq 2

    subpacket0 = packet.packets[0]
    expect(subpacket0.version).to eq 6
    expect(subpacket0.type_id).to eq 4
    expect(subpacket0.value).to eq 10
    subpacket1 = packet.packets[1]

    expect(subpacket1.version).to eq 2
    expect(subpacket1.type_id).to eq 4
    expect(subpacket1.value).to eq 20

    expect(input.length).to eq 7

    input = "11101110000000001101010000001100100000100011000001100000".dup
    packet = Packet.from(input)
    expect(packet.version).to eq 7
    expect(packet.type_id).to eq 3
    expect(packet.packets.length).to eq 3
  end

  it "should solve part 2" do
    expect(parse_input("C200B40A82").value).to eq 3
    expect(parse_input("04005AC33890").value).to eq 54
    expect(parse_input("880086C3E88112").value).to eq 7
    expect(parse_input("CE00C43D881120").value).to eq 9
    expect(parse_input("D8005AC2A8F0").value).to eq 1
    expect(parse_input("F600BC2D8F").value).to eq 0
    expect(parse_input("9C005AC2F8F0").value).to eq 0
    expect(parse_input("9C0141080250320F1802104A08").value).to eq 1

    expect(actual_input.value).to eq 1673210814091
  end
end

run if $PROGRAM_NAME == __FILE__ || $PROGRAM_NAME.end_with?("ruby-memory-profiler")
