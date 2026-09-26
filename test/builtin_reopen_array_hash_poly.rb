# An Array / Hash reopen's method reached through a POLY receiver. A boxed
# array or hash is an object box whose class id names the builtin container
# kind, not the reopen's class, so the dispatch key never selected the
# Array / Hash arm and the call took Object's (or raised). Every container
# kind -- int, string, float and poly arrays; string-, symbol- and int-keyed
# hashes -- has to reach its reopen, with and without an argument.
class Object
  def kind = "obj"
  def kind2(x) = "obj#{x}"
end
class Array
  def kind = "arr#{size}"
  def kind2(x) = "arr#{size}#{x}"
end
class Hash
  def kind = "hash#{size}"
  def kind2(x) = "hash#{size}#{x}"
end
class Thing; end

xs = [[1, 2], %w[a b c], [1.5], [1, "x", nil], [], { "a" => 1 }, { a: 1, b: 2 }, { 1 => 2 }, {}, "s", 3, nil, Thing.new]
xs.each { |x| print x.kind, " " }
puts
xs.each { |x| print x.kind2("!"), " " }
puts
p [[1], {}].map(&:kind)
h = { k: [1, 2, 3] }
v = h[:k]
p v.kind
