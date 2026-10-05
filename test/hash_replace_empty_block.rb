# Hash#replace with an empty `{}` literal empties the receiver, which the
# literal, having no variant of its own, did not match: it raised
# NoMethodError, with or without a block. On a boxed receiver, replace
# with a block answered nil; CRuby ignores the block and answers the hash.

h = {"a" => 1, "b" => 2}
p h.replace({}), h
s = {a: 1, "b" => 2.0}
p s.replace({}), s
n = {1 => 2}
p n.replace({}) { 0 }, n
d = Hash.new(5)
d["a"] = 1
d.replace({})
p d, d["z"]
f = {"a" => 1}.freeze
begin
  f.replace({})
rescue FrozenError => e
  p e.class
end
none = {}
k = {"x" => 1}
p k.replace(none), k

def pick(i) = i > 0 ? {"b" => 2} : {a: 1}
b = pick(1)
p b.replace({"c" => 3}) { 0 }, b
p b.replace({}) { }, b
arr = [1, "x"]
p arr.replace([3]) { 0 }, arr
str = [1].first > 0 ? +"s" : 1
p str.replace("t") { 0 }, str
