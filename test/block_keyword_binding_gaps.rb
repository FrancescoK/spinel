# A block's keyword parameters bind the same way through every caller:
# yield, Proc#call, a lambda, instance_exec, a builtin iterator (an
# Enumerator chain included) and a method made by define_method.

def expect_error
  yield
  p :no_error
rescue ArgumentError => e
  p e.message
end

class Box; end

# instance_exec: a **rest is {} or the extras, never nil
p Box.new.instance_exec(1, k: 4) { |a, k: 0, **r| [a, k, r] }
p Box.new.instance_exec(1, k: 4, z: 5) { |a, k: 0, **r| [a, k, r] }
p Box.new.instance_exec(1) { |a, k: 0, **r| [a, k, r] }
h = {k: 4, z: 1}
p Box.new.instance_exec(1, **h) { |a, k: 0, **r| [a, k, r] }
expect_error { Box.new.instance_exec(q: 1) { |w: 1| w } }
expect_error { Box.new.instance_exec(1) { |a, k:| k } }

# a key naming no keyword raises for a proc and a lambda alike, but a
# **rest takes it
expect_error { proc { |w: 1| w }.call(q: 1) }
expect_error { lambda { |w: 1| w }.call(q: 1) }
expect_error { ->(w: 1) { w }.call(q: 1, r: 2) }
b = proc { |w: 1| w }
expect_error { b.call(w: 2, q: 1) }
expect_error { b.(q: 1) }
expect_error { b.yield(q: 1) }
expect_error { b[q: 1] }
p proc { |w: 1, **o| [w, o] }.call(q: 1)
p proc { |w:| w }.call(w: 2)
p proc { |a, w: 1| [a, w] }.call(5)

# define_method takes keywords as a method does
class Dm
  define_method(:n) { |w: 3| w }
  define_method(:o) { |a, w: 3| [a, w] }
  define_method(:r) { |a, w:| [a, w] }
  define_method(:s) { |a, w: 1, **k| [a, w, k] }
  define_method(:t) { |**k| k }
  define_method(:u) { |k:, **| k }
  def via_self = o(1, w: 7)
end
p Dm.new.n
p Dm.new.n(w: 5)
p Dm.new.o(1)
p Dm.new.o(1, w: 2)
p Dm.new.r(1, w: 2)
p Dm.new.s(1)
p Dm.new.s(1, w: 2, z: 3)
p Dm.new.t(a: 1)
p Dm.new.u(k: 1, j: 2)
p Dm.new.via_self
p Dm.instance_method(:n).parameters
expect_error { Dm.new.n(q: 1) }
expect_error { Dm.new.r(1) }

# a builtin iterator reached through an Enumerator passes no keywords, so
# the defaults apply
p [1, 2].each_with_index.map { |v, i, w: 9| v + i + w }
p [1, 2].map.with_index { |v, i, w: 9| v + i + w }
p [1, 2].each.with_index(1).map { |v, i, w: 9| v + i + w }
p [1, 2].each_with_index.select { |v, i, w: 9| w > 5 }
p [1, 2].each_slice(1).map { |a, w: 9| [a, w] }
p({a: 1}.each_with_index.map { |(k, v), i, w: 9| [k, v, i, w] })
p [1, 2].each_with_index.map { |v, i, w: 9, **o| [v + i + w, o] }
expect_error { [1, 2].each_with_index.map { |v, i, w:| v } }

# an anonymous ** takes the keywords no named one does
def many = yield(k: 1, j: 2)
p(many { |k:, **| k })
p(many { |k: 0, **| k })
p(many { |**| 7 })
def many_pos = yield(3, k: 1, j: 2)
p(many_pos { |a, **| a })
p(many_pos { |a, *r, **| [a, r] })
p proc { |k:, **| k }.call(k: 1, j: 2)
p ->(k:, **) { k }.call(k: 1, j: 2)
p Box.new.instance_exec(k: 1, j: 2) { |k:, **| k }
p [1].map { |v, k: 3, **| v + k }
def call_blk(&b) = b.call(k: 1, j: 2)
p(call_blk { |k:, **| k })
p proc { |a, **| }.parameters
p lambda { |**| }.parameters
