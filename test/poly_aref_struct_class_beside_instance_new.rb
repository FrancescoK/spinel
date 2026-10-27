# `x[...]` on a boxed value that may hold a Data or Struct class is that
# class's `new`. A program that also has an instance method `new` and a
# class with its own `self.new` still reads a Hash or an Array by `[]`,
# and the class arm constructs only the classes it tested for (#10325).
Point = Data.define(:x, :y)
Pair = Struct.new(:a, :b)

class Maker
  def new(x) = [:made, x]
end

class Counter
  def self.new = 0
end

class Box
  def initialize(v) = @v = v
  attr_reader :v
end

def get(row, k) = row[k]
def get2(row, a, b) = row[a, b]

rows = [{ "name" => "n0" }, [10, 20, 30], Point, Pair]
rows.each do |r|
  case r
  when Hash then p get(r, "name")
  when Array then p [get(r, 1), get2(r, 0, 2)]
  else p get2(r, 1, 2)
  end
end
p Maker.new.new(3), Counter.new, Box.new("v").v
p Box.new("w").v
