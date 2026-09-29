# OpenStruct runtime helpers on an object that nothing but the call holds: a
# method's return value, typed, and the same read out of a mixed slot. Each
# helper allocates while it reads that object (inspect, to_h, a member's ==
# or eql?, OpenStruct.new copying a Hash), so it keeps the object rooted;
# unrooted, the calls answered wrong, crashed or did not finish.
require "ostruct"

def mk(i) = OpenStruct.new(a: "s#{i}", b: [i, "t#{i}"], c: "u" * (i % 50))
def mix(i) = i.even? ? mk(i) : [[:x, i]]

def want_s(i) = %(#<OpenStruct a="s#{i}", b=[#{i}, "t#{i}"], c="#{"u" * (i % 50)}">)
def want_h(i) = {a: "s#{i}", b: [i, "t#{i}"], c: "u" * (i % 50)}

bad = 0
100000.times { |i| bad += 1 unless mk(i).inspect == want_s(i) }
p bad

bad = 0
100000.times { |i| bad += 1 unless i.odd? || mix(i).inspect == want_s(i) }
p bad

bad = 0
20000.times { |i| bad += 1 unless mk(i).to_s == want_s(i) && "#{mk(i)}" == want_s(i) }
p bad

bad = 0
100000.times { |i| bad += 1 unless mk(i).to_h == want_h(i) }
p bad

bad = 0
100000.times { |i| bad += 1 unless i.odd? || mix(i).to_h == want_h(i) }
p bad

# members whose == and eql? allocate
class Q
  attr_reader :v
  def initialize(v) = (@v = v)
  def ==(o) = ("#{@v}x" + "y" * (@v % 40)) == ("#{o.v}x" + "y" * (o.v % 40))
  def eql?(o) = ("#{@v}x" + "y" * (@v % 40)) == ("#{o.v}x" + "y" * (o.v % 40))
  def hash = @v.hash
end
def mkq(i) = OpenStruct.new(q1: Q.new(i), s: "s#{i}", q2: Q.new(i), t: ["t#{i}", i], q3: Q.new(i))
def mixq(i) = i.even? ? mkq(i) : [[:x, i]]

bad = 0
20000.times { |i| x = mkq(i); bad += 1 unless x == mkq(i) }
p bad

bad = 0
20000.times { |i| x = mixq(i); bad += 1 unless i.odd? || mixq(i) == x }
p bad

bad = 0
20000.times { |i| x = mkq(i); bad += 1 unless x.eql?(mkq(i)) }
p bad

# OpenStruct.new(hash) with Symbol and with String keys
def mkh(i) = {a: "s#{i}", b: [i, "t#{i}"], c: "u" * (i % 50)}
def mks(i) = {"a" => "s#{i}", "b" => [i, "t#{i}"], "c" => "u" * (i % 50)}

bad = 0
20000.times { |i| bad += 1 unless OpenStruct.new(mkh(i)).to_h == want_h(i) }
p bad

bad = 0
20000.times { |i| bad += 1 unless OpenStruct.new(mks(i)).to_h == want_h(i) }
p bad

# a typed OpenStruct slot left nil reaches to_h as a null
class Holder
  attr_reader :os
  def initialize(f) = (@os = OpenStruct.new(a: 2) if f)
end
p Holder.new(false).os.to_h
p Holder.new(true).os.to_h

p mk(7).to_h
p mix(8)
