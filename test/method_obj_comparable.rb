# Integer, String and Symbol answer Comparable's methods (between?, clamp and
# the comparisons a class does not define itself) through method(:sym): the
# name raised NameError, as the class's own table leaves the module's out.
m = 5.method(:between?)
p m.call(1, 9), m.call(6, 9)
p m.arity, m.name, m.owner
c = 5.method(:clamp)
p c.call(1, 3), c.call(7, 9), c.arity
p 5.method(:<).call(6), 5.method(:>=).call(6)
p "m".method(:between?).call("a", "z"), "m".method(:clamp).call("n", "z")
p :b.method(:between?).call(:a, :c), :b.method(:<).call(:c)
p [3, 9, 5].select(&4.method(:<))
begin
  5.method(:between?).call(1)
rescue ArgumentError => e
  p e.message
end
p "m".method(:<).owner, "m".method(:<).arity, 5.method(:<).owner
p :b.method(:clamp).owner, :b.method(:clamp).arity
