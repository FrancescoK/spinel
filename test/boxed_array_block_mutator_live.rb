# A block mutator over a boxed Array runs on the Array itself: what the block
# does to its receiver is seen by the next step and kept afterwards.
def strs(n) = n > 0 ? ["a:1", "b"] : 42
def ints(n) = n > 0 ? [1, 2, 3] : "s"

args = strs(1)
args.reject! { |x| args << "c" if x == "a:1"; x == "a:1" }
p args

nums = ints(1)
nums.select! { |x| nums << 9 if x == 1; x != 2 }
p nums

k = strs(1)
p(k.keep_if { |x| k << "z" if x == "b"; true })
p k

d = strs(1)
d.delete_if { |x| d[1] = "B" if x == "a:1"; false }
p d

e = ints(1)
e.delete_if { |x| e.clear if x == 2; false }
p e

m = strs(1)
m.map! { |x| m << "q" if x == "b"; x * 2 }
p m

c = strs(1)
c.collect! { |x| c.pop if x == "a:1"; x + "!" }
p c

mi = ints(1)
p(mi.map! { |x| mi << 4 if x == 1; x * 10 })
p mi

# nil when every element the loop reached was kept, appended ones included
s = ints(1)
p(s.select! { |x| s << 7 if x == 3; true })
p s
r = ints(1)
p(r.reject! { |x| x == 2 })
p r

# an early exit cuts the array where the loop left it
b = ints(1)
b.reject! { |x| break if x == 3; x == 1 }
p b

class Expander
  attr_reader :args
  def initialize(a) = @args = a
  def run
    args.reject! { |f| args << "#{f}.rb" if f.end_with?(":1"); f.end_with?(":1") }
    args
  end
end
p Expander.new(strs(1)).run

f = strs(1).freeze
begin
  f.reject! { true }
rescue FrozenError => ex
  p ex.class
end
p f
