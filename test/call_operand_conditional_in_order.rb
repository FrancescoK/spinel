# A conditional among a call's operands runs in its place: the operands
# around it read the stream in the order written, whatever order C
# evaluates a call's arguments in.

class Reader
  def initialize(values)
    @values = values
    @at = 0
  end

  def int
    value = @values[@at]
    @at += 1
    value
  end
end

Record = Data.define(:first, :second, :third, :fourth, :fifth)
Pair = Struct.new(:left, :right)

class Record
  NAMES = %i[none some].freeze

  def self.name_for(name) = name == :none ? nil : name

  def self.size(value) = value.zero? ? nil : value

  def self.read(reader)
    new(first: reader.int, second: name_for(NAMES.fetch(reader.int)), third: size(reader.int),
        fourth: reader.int > 0 ? reader.int : 0, fifth: reader.int)
  end
end

def three(a, b, c) = [a, b, c]
def kw(a:, b:, c:) = [a, b, c]

record = Record.read(Reader.new([7, 1, 3, 1, 5, 6]))
puts "#{record.first} #{record.second.inspect} #{record.third.inspect} #{record.fourth} #{record.fifth}"
r = Reader.new((1..20).to_a)
p three(r.int, r.int.odd? ? r.int : -1, r.int)
p kw(a: r.int, b: (r.int unless r.int.zero?), c: r.int)
p kw(a: r.int, b: r.int > 100 ? r.int : nil, c: r.int)
p Pair.new(r.int, r.int.even? ? r.int : 0)
