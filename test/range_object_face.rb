# Object's own methods on a String or a Float Range answer about the Range
# itself. A String Range routed every name it had no endpoint arm for through
# its member Array, so tap and then yielded that Array, tap and each answered
# it, and on an endless range instance_variables, `!` and `=~` raised
# RangeError. A Float Range typed those names as unknown: tap and then
# answered nil, `!` answered 0 and instance_variables raised NoMethodError.

s = ("a".."c")
e = ("e".."a")
u = ("a"..)
f = (1.0..2.5)
g = (..2.5)
h = (1.0..)

# tap / then / yield_self yield the range
p s.tap { |q| q }
p e.tap { |q| q }
p u.tap { |q| q }
p f.tap { |q| q }
p h.tap { |q| q }
p s.then { |q| q.begin }
p e.then { |q| q.begin }
p u.then { |q| q.begin }
p f.then { |q| q.end }
p g.yield_self { |q| q.end }
p [g.then { |q| q.begin }, h.then { |q| q.end }]
t = s.tap { |q| }
p t
t2 = f.tap { |q| }
p t2

# the self-answering walks run their block and answer the range
seen = []
p(s.each { |x| seen << x })
p(s.each_entry { |x| seen << x })
p(s.reverse_each { |x| seen << x })
p(s.each_with_index { |x, i| seen << i })
p(s.each_slice(2) { |x| seen << x.size })
p(s.each_cons(2) { |x| seen << x.join })
p(e.each { |x| seen << x })
p seen

# Object's reflection and operators
p [!s, !u, !f, !g, !h]
p [0, !f]
p s.instance_variables, u.instance_variables, f.instance_variables, g.instance_variables
p u.instance_variable_get(:@x)
p [u.object_id == u.object_id, f.object_id == f.object_id]
p((s =~ /a/ rescue $!.class))
p((u =~ /a/ rescue $!.class))
p((f =~ /a/ rescue $!.class))
