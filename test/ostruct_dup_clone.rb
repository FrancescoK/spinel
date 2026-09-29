# OpenStruct#dup and #clone make a new OpenStruct with its own member table:
# a write through the copy leaves the original alone, and the member values
# themselves stay shared. clone keeps the frozen state, dup does not.
require "ostruct"

o = OpenStruct.new(a: 1, s: "str")
d = o.dup
c = o.clone
d.a = 2
c.a = 3
p [o.a, d.a, c.a]
d.b = 9
p [o.respond_to?(:b), o.to_h, d.to_h, c.to_h]
p [d.equal?(o), c.equal?(o), d.s.equal?(o.s)]
o[:a] = 7
p [o.a, d.a, c.a]

# frozen: dup is a writable copy, clone stays frozen
f = OpenStruct.new(a: 1).freeze
fd = f.dup
fc = f.clone
p [f.frozen?, fd.frozen?, fc.frozen?]
fd.a = 2
p [f.a, fd.a]
begin
  fc.a = 3
rescue FrozenError => e
  p e.class
end
p [OpenStruct.new.clone.frozen?, OpenStruct.new.dup.frozen?]

# boxed: an OpenStruct read out of a mixed value
def mk(i) = i.even? ? OpenStruct.new(a: i) : [i]
x = mk(2)
p [x.dup.equal?(x), x.clone.equal?(x), x.dup == x, x.dup.a]
x.freeze
p [x.frozen?, x.dup.frozen?, x.clone.frozen?]
w = OpenStruct.new(a: 1)
bd = [w, 1][0].dup
w.a = 2
p [w.a, bd.a]

# copies made in a block
os = [OpenStruct.new(a: 1), OpenStruct.new(a: 2)]
ds = os.map(&:dup)
p ds.map(&:a), ds.zip(os).map { |e, f| e.equal?(f) }
p os.map { |e| e.clone }.zip(os).map { |e, f| e.equal?(f) }

# a typed OpenStruct slot left nil copies to nil
class Holder
  attr_reader :os
  def initialize(f) = (@os = OpenStruct.new(a: 1) if f)
end
p Holder.new(false).os.dup
p Holder.new(true).os.dup.to_h

# a copy of a temporary that nothing else holds
def mkt(i) = OpenStruct.new(a: "s#{i}", b: [i, "t#{i}"], c: "u" * (i % 50))
def mixt(i) = i.even? ? mkt(i) : [i]
def want_h(i) = {a: "s#{i}", b: [i, "t#{i}"], c: "u" * (i % 50)}
bad = 0
20000.times { |i| t = mkt(i).dup; bad += 1 unless t.to_h == want_h(i) }
p bad
bad = 0
20000.times { |i| t = mkt(i).clone; bad += 1 unless t.to_h == want_h(i) }
p bad
bad = 0
20000.times { |i| next if i.odd?; t = mixt(i).dup; bad += 1 unless t.to_h == want_h(i) }
p bad
def mkf(i) = OpenStruct.new(a: "s#{i}", b: [i, "t#{i}"]).freeze
bad = 0
20000.times { |i| t = mkf(i).clone; bad += 1 unless t.frozen? && t.a == "s#{i}" }
p bad
