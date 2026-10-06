# nil's answer where the slot holding nil has a type of its own: the value
# nil's method answers lands in the slot the class's answer would. A
# String's <=> is an Integer slot, and nil's 0-or-nil rides there (nil as
# the sentinel, so it still boxes, compacts and keys a Hash as nil); an
# Integer Array's to_a and a Hash's to_h build their empty answer in the
# slot's own kind. Beside them: a boxed value's object_id for nil, true,
# false and an Integer, and `!~` on an Array or a Hash, which asks their
# missing =~ and raises.

def v(k) = k == 0 ? nil : "s#{k}"
p v(0) <=> nil, v(0) <=> 1, v(0) <=> "a", v(1) <=> nil, v(1) <=> "s1", v(1) <=> 1
x = v(0) <=> 2
p x, x.nil?, [x].compact, { x => 1 }
y = v(1) <=> 5
p y.nil?, (y || :none)

def ia(a = nil) = a
ia([1, 2]) if ARGV.size == 9
def hs(h = nil) = h
hs({ "k" => 1 }) if ARGV.size == 9
p ia.to_a, ia.to_a.size, hs.to_h, hs.to_h.empty?, ia.to_a.push(3)

xs = [nil, true, false, 3, -2, :q, 1.5, "s", [1], 7]
xs.each { |e| p [e.object_id == e.object_id, (e.object_id if e.nil? || e == true || e == false || e.is_a?(Integer))] }

a = [1]
p((a !~ /a/ rescue $!.message))
h = { a: 1 }
p((h !~ /a/ rescue $!.message))
