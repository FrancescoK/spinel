# A method defined in a reopened Struct is inherited by every Struct.new
# class, and a struct class's own method still overrides it.
class Struct
  def as_json
    to_h
  end

  def label
    "struct"
  end
end

Point = Struct.new(:x, :y)
Pair = Struct.new(:a, :b) do
  def label
    "pair #{a}"
  end
end

class Size < Struct.new(:w, :h)
end

p Point.new(1, 2).as_json
p Pair.new(3, 4).as_json
puts Point.new(1, 2).label
puts Pair.new(3, 4).label
p Size.new(5, 6).as_json
[Point.new(7, 8), Pair.new(9, 10)].each { |s| p s.public_send(:as_json) }
