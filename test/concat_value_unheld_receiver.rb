# Array#concat as a value, on an Array no variable holds, with Arrays of
# another kind: a literal, a method's value and an Array a builtin call
# just built. CRuby answers the receiver with the other elements added,
# Integers beside Floats as Integers. Spinel built the receiver as a typed
# Array and the call had no arm (NoMethodError), or the C did not build.

p ["q"].concat([1, 2])
p [1].concat(["s"]).size
p [1.5].concat([1])
p [1].concat([2], ["s"])
p [1].concat([nil, "x"])
p [1].unshift("s")
p [1].insert(0, "s")
3.times { |i| p [i].concat([:s]) }

def strs = ["s"]
def flts = [1.5]
def held
  a = [1]
  a
end
p strs.concat([1])
p strs
p flts.concat([2])
p flts.push(1)
p flts.concat([2]).map(&:class)
p strs.concat([2], ["t"])
p held.concat(["u"])

class K
  def self.make = ["k"]
  def items = [1]
  def more = items.concat(["v"])
end
p K.make.concat([1])
p K.new.more

p "a b".split.concat([1])
p "a b".split.concat([1], [2.5])
p (1..3).to_a.concat(["s"])
p [3, 1].sort.concat([nil, "x"])
x = "a b".split.concat([1])
x << :q
p x, x.size
"a b".split.concat([1])
p "a b".split.concat(["c"])
p [1.5].map { |x| x } << 1
p "1.5 2".split.map(&:to_f).push(3)
p [1.5].map { |x| x }.concat([1])
