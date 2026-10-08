class Pairs
  def to_hash = {c: 3}
end

class Conflict
  def to_hash = {a: 9, c: 3}
end

class StrPairs
  def to_hash = {"c" => 3}
end

class NoHash
end

def bx(v) = [v, 1][0]

h = {a: 1}
h.merge!(Pairs.new)
p h
u = {a: 1}
u.update(Pairs.new)
p u
w = {a: 1}
r = w.merge!({b: 2}, Pairs.new)
p r, w
k = {a: 1}
k.merge!(Conflict.new) { |_key, old, new| old + new }
p k
s = {"a" => 1}
s.merge!(StrPairs.new)
p s
bh = bx({a: 1})
bh.merge!(Pairs.new)
p bh
begin
  {a: 1}.merge!(NoHash.new)
rescue TypeError => e
  puts e.message
end

class Sep
  def to_str = "-"
end

class Count
  def to_int = 2
end

class Both
  def to_str = "+"
  def to_int = 3
end

p [1, 2] * Sep.new
p [1, 2] * Count.new
p [1, 2] * Both.new
p ["x", "y"] * Count.new
p "ab" * Count.new

def by(v) = [v, "x"][0]
p [10, 20, 30].values_at(*[by(1..2)])
p [10, 20, 30].values_at(*[by(0), by(1..2)])
p [10, 20, 30].values_at(*[by(0...2), by(2)])
p [10, 20, 30].values_at(*[by(1..5)])
idx = [by(1..2), by(0)]
p [10, 20, 30].values_at(*idx)
