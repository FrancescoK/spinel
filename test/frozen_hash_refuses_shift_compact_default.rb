# A frozen Hash refuses `shift`, `compact!`, `default=` and `default_proc=`, and
# a `merge!` or `update` of an empty Hash, with FrozenError whose receiver is the
# Hash, as it refuses every other mutator. They used to change it, or answer, and
# `default=` evaluates its value before it refuses.
def refused(h)
  yield
  :no_error
rescue FrozenError => e
  [e.class, e.receiver.equal?(h)]
end

pr = proc { |_, _| 7 }

sym = { a: 1, b: nil }.freeze
str = { "k" => 1 }.freeze
int = { 1 => 2 }.freeze
ss = { "a" => "b" }.freeze
is = { 1 => "b" }.freeze
mixed = { 1 => "x", "y" => 2, z: nil }.freeze
one = { a: "s" }.freeze

p refused(sym) { sym.shift }
p refused(str) { str.shift }
p refused(int) { int.shift }
p refused(ss) { ss.shift }
p refused(is) { is.shift }
p refused(mixed) { mixed.shift }
e = {}.freeze
p refused(e) { e.shift }

p refused(sym) { sym.compact! }
p refused(one) { one.compact! }
p refused(mixed) { mixed.compact! }
p refused(e) { e.compact! }

p refused(sym) { sym.merge!({}) }
p refused(str) { str.merge!({}) }
p refused(int) { int.update({}) }
p refused(ss) { ss.merge!({}) }
p refused(is) { is.update({}) }
p refused(mixed) { mixed.merge!({}) }
p refused(e) { e.update({}) }

p refused(sym) { sym.default = 2; nil }
p refused(str) { str.default = 2; nil }
p refused(int) { int.default = 2; nil }
p refused(ss) { ss.default = "d"; nil }
p refused(is) { is.default = "d"; nil }
p refused(mixed) { mixed.default = :d; nil }
p refused(one) { one.default = "d"; nil }

p refused(sym) { sym.default_proc = pr; nil }
p refused(mixed) { mixed.default_proc = pr; nil }
p refused(one) { one.default_proc = pr; nil }
p refused(sym) { sym.default_proc = ->(h, k) { 3 }; nil }
p refused(mixed) { mixed.default_proc = ->(h, k) { 3 }; nil }

# nothing about the Hash changed, and the value was evaluated first
p sym, str, int, ss, is, mixed, one, e
p [sym.default, str.default, int.default, ss.default, is.default, mixed.default, one.default]
p [sym.default_proc, mixed.default_proc, one.default_proc]
log = []
begin
  str.default = (log << :value; 5)
rescue FrozenError
  log << :refused
end
p log

# and for each kind of value the Hash holds
log = []
begin; sym.default = (log << :poly; 5); rescue FrozenError; log << :refused; end
begin; int.default = (log << :int; 3); rescue FrozenError; log << :refused; end
begin; ss.default = (log << :str; "d"); rescue FrozenError; log << :refused; end
begin; sym.default_proc = (log << :proc; pr); rescue FrozenError; log << :refused; end
p log

# the same calls on a Hash that is not frozen
u = { a: 1, b: nil }
p u.shift
p u.compact!
p u.compact!
p u.merge!({})
u.default = 4
p u[:nope]
u.default_proc = pr
p u[:nope]
s = { "k" => 1, "j" => 2 }
p s.shift
p s.update({})
s.default = 9
p s["none"]
i = { 1 => "b", 2 => "c" }
p i.shift
i.default = "d"
p i[5]
m = { 1 => "x", "y" => 2, z: nil }
p m.shift
p m.compact!
p m
