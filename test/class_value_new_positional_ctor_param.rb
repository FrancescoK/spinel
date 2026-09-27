# A class-value `k.new(x)` with no static `K.new(x)` beside it: its argument
# still types the initialize it reaches, so the dispatch has an arm for it.

class Parsed
  attr_reader :name

  def initialize(name) = @name = name
end

Synth = Data.define(:name)

class Base
  attr_reader :name

  def initialize(src) = @name = src.name
end

class Plain < Base; end

class Special < Base
  def initialize = super(Synth.new(name: "special"))
end

MAPPERS = { 0 => Plain }.freeze

def build(src) = MAPPERS.fetch(0).new(src)

klass = [Plain][0]
puts Special.new.name
puts klass.new(Parsed.new("from an array")).name
puts build(Parsed.new("from a hash")).name
puts build(Synth.new(name: "synth")).name

class Box
  attr_reader :v

  def initialize(v) = @v = v
end

class One < Box
  def initialize = super(1)
end

class Holder
  def initialize(k) = @k = k
  def make(x) = @k.new(x)
end

REG = { "b" => Box }

p One.new.v
p REG["b"].new("str").v
p Holder.new(Box).make(2.5).v
p [Box][0].new([1, 2]).v

class Tune
  def to_s = "tune"
end

class TypedA
  def initialize(x) = @x = x
  def show = "A #{@x}"
end

class TypedB
  def initialize(x) = @x = x
  def show = "B #{@x}"
end

class TypedC
  def initialize(x, lv: 1) = @x = x
  def show = "C #{@x}"
end

puts TypedB.new(3).show
puts TypedC.new(4.5).show
3.times { |i| puts [TypedA, TypedB, TypedC][i].new(Tune.new).show }
