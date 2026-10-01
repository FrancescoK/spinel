# Array#fetch's block answers a `next <v>` value on a miss, on a typed
# array, a mixed array and a receiver of no single type.
a = [10, 20]
p a.fetch(7) { |i| next 42 if i == 7; 0 }
p a.fetch(8) { |i| next 42 if i == 7; 0 }
p a.fetch(1) { |i| next 42 if i == 7; 0 }
s = ["x", "y"]
p s.fetch(5) { |i| next "far" if i > 3; "near" }
p s.fetch(2) { |i| next "far" if i > 3; "near" }
m = [1, "x"]
p m.fetch(9) { |i| next :nine if i == 9; nil }

class Box
  def initialize(k); @v = k == 0 ? [10, 20] : {a: 1}; end
  def f(key) = @v.fetch(key) { |x| next 42 if x == 7 || x == :q; 0 }
end
p Box.new(0).f(7), Box.new(0).f(8), Box.new(0).f(-1)
p Box.new(1).f(:q), Box.new(1).f(:r), Box.new(1).f(:a)
