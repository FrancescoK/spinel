# A bare `super` from a method with a rest passes its positionals as one list,
# and which of them a parameter of the parent takes depends on how many there
# are. A fixed parameter that can be nil (`b = nil`) reaches an Integer or Float
# optional of the parent that follows another optional (`def m(a, b = 7, z)`)
# that way: Ruby funds the parent's parameters from the list by their count,
# not at their own positions. The parent's slot has to keep that nil; it
# answered 0 (an Integer) or raised TypeError (a Float). The last two parents
# take a post after a rest, which is a boxed slot and always kept the nil.
def t
  yield
rescue ArgumentError, TypeError => e
  e.class
end

class P1
  def m(a, b = 7, z) = [a, b, z]
end
class Q1 < P1
  def m(a, b = nil, c = nil, *r) = super
end
class Q2 < P1
  def m(a, b = nil, *r, w) = super
end
p P1.new.m(1, 2)
p t { Q1.new.m(1) }, t { Q1.new.m(1, 2) }, t { Q1.new.m(1, 2, 3) }, t { Q1.new.m(1, 2, 3, 4) }
p t { Q2.new.m(1, 2) }, t { Q2.new.m(1, 2, 3) }, t { Q2.new.m(1, 2, 3, 4) }

class P3
  def m(a, b = 7.5, z) = [a, b, z]
end
class Q3 < P3
  def m(a, b = nil, c = nil, *r) = super
end
p P3.new.m(1.5, 2.5)
p t { Q3.new.m(1.5) }, t { Q3.new.m(1.5, 2.5) }, t { Q3.new.m(1.5, 2.5, 3.5) }

class P4
  def m(a, *r, z) = [a, r, z]
end
class Q4 < P4
  def m(a, b = nil, *r) = super
end
p P4.new.m(1, 2, 3)
p t { Q4.new.m(1) }, t { Q4.new.m(1, 2) }, t { Q4.new.m(1, 2, 3) }

class P5
  def m(a, *r, y, z) = [a, r, y, z]
end
class Q5 < P5
  def m(a, b = nil, c = nil, *r) = super
end
p P5.new.m(1, 2, 3, 4)
p t { Q5.new.m(1, 2) }, t { Q5.new.m(1, 2, 3) }, t { Q5.new.m(1, 2, 3, 4) }
