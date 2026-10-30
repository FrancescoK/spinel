# replace into a hash parameter of a hash that is itself a boxed parameter,
# its callers passing hashes of different kinds: each call's hash for it is
# checked against the receiver's, and a receiver that cannot hold its keys or
# values widens, as merge! does. The old entries go, and the caller sees it.
def assign(obj, source)
  obj.replace(source)
  obj
end
p assign({ "a" => 1 }, { "b" => 2 })
p assign({ "c" => "x" }, { "d" => [1] })
x = { "q" => :s }
p assign(x, { "e" => 1 })
p x

# the receiver of one kind, only the source boxed
def only_source(obj, source) = obj.replace(source)
p only_source({ "c" => "x" }, { "b" => 2 })
p only_source({ "c" => "x" }, { "d" => [1] })

# another key kind, and an empty [] or {} in the literal
def keyed(obj, source) = (obj.replace(source); obj)
p keyed({ 1 => 2 }, { 3 => 4 })
p keyed({ 1 => 2 }, { "k" => 1.5 })
p keyed({ "a" => 1 }, { "k" => [] })
p keyed({ "a" => 1 }, { "k" => {} })

# a caller handing its own parameters on stores them the same way
def outer(o, s) = assign(o, s)
p outer({ "a" => 1 }, { "b" => 2 })
p outer({ "c" => "x" }, { :d => [1] })

# a source of boxed values is left to the store, and a nil value fits
def entry(v) = { "n" => v }
label = entry("x")
def into(obj, source)
  obj.replace(source)
  nil
end
h = { "a" => 1 }
into(h, entry(2))
p h
into({ 1 => 2 }, { 3 => 4 })
p label
into(h, { "c" => nil })
p h

# a String or an Array receiver keeps its own replace
def same(o, s) = o.replace(s)
p same(+"ab", "cd")
p same([1], [2])
p same({ "a" => 1 }, { "b" => 2 })
