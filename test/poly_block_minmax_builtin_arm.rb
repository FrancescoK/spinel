# spinel: gc-stress
# min / max with a comparing block and min_by / max_by, on a poly receiver
# whose dispatch exists because a user class owns the name (an attr_reader,
# or a yielding method): an Array, Hash, Range or Set reaching it still
# answers with its own method, keeping the first winner on a tie.
require "set"

class Rep
  attr_reader :max, :min

  def initialize(m)
    @max = m
    @min = -m
  end
end

class Pool
  def initialize(xs)
    @xs = xs
  end

  def max_by
    @xs.max_by { |x| yield x }
  end

  def min_by
    @xs.min_by { |x| yield x }
  end
end

def longest(o)
  o.max { |a, b| a.to_s.length <=> b.to_s.length }
end

def shortest(o)
  o.min { |a, b| a.to_s.length <=> b.to_s.length }
end

def widest(o)
  o.max_by { |x| x.to_s.length }
end

def narrowest(o)
  o.min_by { |x| x.to_s.length }
end

[Rep.new(3), [1, "abc", 22, "xyz"], [], { "a" => 1, "bb" => 22 }, (1..12), Set["x", "yyy", "zz"]].each do |v|
  p longest(v)
  p shortest(v)
end

[Pool.new(["aa", "b", "ccc", "ddd"]), ["aa", "b", "ccc", "ddd", "e"], [], (5..12), { "k" => 1, "kkk" => 2 }].each do |v|
  p widest(v)
  p narrowest(v)
end

h = [Pool.new([1]), { "k" => 10, "kkk" => 2 }][1]
p h.max_by { |_k, n| n }
p h.min_by { |_k, n| n }

begin
  [Rep.new(1), [3, 1, 2]][1].max { |_a, _b| nil }
rescue ArgumentError => e
  puts e.message
end

# a generator-backed Enumerator is walked to its end, and Range#max / #min
# refuse an endless or beginless Range before asking the block
class Gen
  attr_reader :max, :min, :sort_by
end
g1 = Enumerator.new { |y| y << 1; y << 5; y << 3 }
p [Gen.new, g1][1].max { |a, b| a <=> b }
g2 = Enumerator.new { |y| y << 1; y << 5; y << 3 }
p [Gen.new, g2][1].sort_by { |x| -x }
[(1..), (..5)].each do |r|
  begin
    p [Gen.new, r][1].max { |a, b| a <=> b }
  rescue RangeError => ex
    puts ex.message
  end
end
begin
  p [Gen.new, (..5)][1].min { |a, b| a <=> b }
rescue RangeError => ex
  puts ex.message
end
