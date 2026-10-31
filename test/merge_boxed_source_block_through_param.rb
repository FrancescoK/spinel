# merge!/update with a conflict block, into a hash parameter of a hash that is
# itself a boxed parameter: what the block answers lands under a colliding key,
# so each call's hash is checked against it too, and one that cannot hold it
# widens.
def assign(obj, source)
  obj.merge!(source) { |_k, a, b| [a, b] }
  obj
end
p assign({ "a" => 1 }, { "a" => 2 })
p assign({ "c" => "x" }, { "c" => "y" })
x = { "q" => :s }
p assign(x, { "q" => 1 })
p x

# update, a String into Integer values, and no key colliding
def upd(obj, source) = obj.update(source) { "s" }
p upd({ "a" => 1 }, { "a" => 2 })
p upd({ "c" => 1.5 }, { "d" => "e" })

# the block's value through a next, an empty [] among them, and a local the
# block writes
def nx(obj, source)
  n = 0
  obj.merge!(source) do |_k, a, b|
    n += 1
    next [] if a == b
    [a, b, n]
  end
end
p nx({ "a" => 1 }, { "a" => 1 })
p nx({ "b" => "x" }, { "b" => "y" })

# a value every receiver can hold leaves them as they are, and nil fits any
def fits(obj, source) = obj.merge!(source) { |_k, a, _b| a }
p fits({ "a" => 1 }, { "a" => 2 })
p fits({ "b" => "x" }, { "b" => "y" })
def none(obj, source) = obj.merge!(source) { nil }
p none({ "a" => 1 }, { "a" => 2 })
p none({ "b" => "x" }, { "b" => "y" })

# a block that breaks stores nothing: its value is the call's
def brk(obj, source) = obj.merge!(source) { |_k, a, b| break [a, b] }
p brk({ "a" => 1 }, { "a" => 2 })
p brk({ "c" => "x" }, { "c" => "y" })

# a value read back is the block's, whatever the receiver's literal held
def rb(obj, source) = obj.merge!(source) { |_k, a, b| [a, b] }
h = { "a" => 1 }
rb(h, { "a" => 2 })
rb({ "c" => "x" }, { "c" => "y" })
v = h["a"]
puts(v.is_a?(Array) ? "array" : "not array")
h.each { |_k, e| puts(e.is_a?(Array) ? "array" : "not array") }
def rt(obj, source) = obj.merge!(source) { |_k, a, b| a == b ? [a] : [b] }
g = { "a" => 1 }
rt(g, { "a" => 2 })
rt({ "c" => "x" }, { "c" => "y" })
w = g["a"]
puts(w.is_a?(Array) ? "array" : "not array")
def rh(obj, source) = obj.merge!(source) { |_k, a, _b| { "k" => a } }
p rh({ "a" => 1 }, { "a" => 2 })
p rh({ "c" => "x" }, { "c" => "y" })

# every block is asked, the first fitting or not
def blocks(obj, s)
  obj.merge!(s) { |_k, x, _y| x }
  obj.merge!(s) { |_k, x, y| [x, y] }
  obj
end
p blocks({ "a" => 1 }, { "a" => 2 })
p blocks({ "c" => "x" }, { "c" => "y" })

# a source that is no parameter itself
def from_local(obj, s)
  t = s
  obj.merge!(t) { |_k, x, y| [x, y] }
end
p from_local({ "a" => 1 }, { "a" => 2 })
p from_local({ "c" => "x" }, { "c" => "y" })

# the receiver of one kind, only the source boxed
def only_source(obj, source) = obj.merge!(source) { |_k, a, b| [a, b] }
p only_source({ "a" => 1 }, { "a" => 2 })
p only_source({ "a" => 1 }, { "a" => "y" })

# a caller handing its own parameters on
def outer(o, s) = assign(o, s)
p outer({ "a" => 1 }, { "a" => 2 })
p outer({ "c" => :x }, { "c" => :y })

# a typed source beside the boxed one
def two(obj, a, b) = obj.merge!(a, b) { |_k, x, y| [x, y] }
p two({ "a" => 1 }, { "a" => 2 }, { "a" => 3 })
p two({ "a" => 1 }, { "a" => 2 }, { "a" => "z" })

# a frozen receiver raises after the source has been evaluated
def evaluated(v) = (puts "evaluated"; v)
def frozen_into(o, s)
  o.merge!(evaluated(s)) { |_k, x, y| [x, y] }
  o
rescue FrozenError => e
  puts e.class
  o
end
p frozen_into({ "a" => 1 }, { "a" => 2 })
p frozen_into({ "c" => "x" }, { "c" => "y" })
p frozen_into({ "c" => "x", 1 => 2 }.freeze, [{ "c" => "y" }, 5][0])
