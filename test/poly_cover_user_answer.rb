# cover? on a boxed receiver answers what the receiver's own cover?
# answers: a class of the program's own whose cover? answers "odd", 2, or
# a boxed @v (nil or 7) keeps that answer, and a Range beside it still
# answers true or false, false for an argument of no class it covers.
class Odd
  def cover?(x) = "odd"
end

class Even
  def cover?(x) = 2
end

class Gate
  def initialize(v) = @v = v
  def cover?(x) = @v
end

def pick(a, i) = a[i]
rs = [Odd.new, Even.new, Gate.new(nil), Gate.new(7),
      (2.0..3.0), ("b".."d"), (1..5), (1.0..), (..2.5)]
p pick(rs, 0).cover?(1), pick(rs, 1).cover?(1)
p pick(rs, 2).cover?(1), pick(rs, 3).cover?(1)
p pick(rs, 4).cover?(2.5), pick(rs, 5).cover?("c"), pick(rs, 6).cover?(3)
p pick(rs, 4).cover?("a"), pick(rs, 5).cover?(3), pick(rs, 6).cover?("x")
p pick(rs, 4).cover?(:s), pick(rs, 7).cover?("q"), pick(rs, 8).cover?(nil)
p pick(rs, 4).cover?(2..3), pick(rs, 5).cover?(1..2), pick(rs, 6).cover?([1])
r = pick(rs, 0).cover?(1)
p r.upcase
begin
  pick([1, :x], 1).cover?(1)
rescue NoMethodError => e
  puts e.message
end
