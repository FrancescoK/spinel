# `x.send(:m)` reaches a top-level `def m` (Object's private method) only
# when x's class does not define m first. A boxed receiver, and a builtin
# one whose class defines the name, were sent to the top-level def instead.

def k(**h) = :top
class A; def k(**h) = :a; end
class B; def k(**h) = :b; end

o = [A.new, B.new][ARGV.size]
p o.send(:k, **{x: 1})
p o.send(:k, x: 1)
p o.send(:k)
p o.__send__(:k, x: 1)
p [A.new, B.new][1].send(:k)

# a class without the name reaches the top-level def, boxed or not
class C; end
p [A.new, C.new][1].send(:k)
p C.new.send(:k)
p [A.new, 5][1].send(:k)
p 5.send(:k)

# a builtin's own method comes before the top-level def
def abs = :top
def upcase = :top
p 5.send(:abs)
p (-7).send(:abs)
p "a".send(:upcase)

# and so do the methods of the modules it includes ahead of Object
def between?(a, b) = :top
p 5.send(:between?, 1, 9)
p 2.5.send(:between?, 1, 9)
p "b".send(:between?, "a", "c")

# the arguments run once, whichever method answers
$l = []
def lg(x) = ($l << x; x)
def m(v) = [:top, v]
class A; def m(v) = [:a, v]; end
p [A.new, 1][0].send(:m, lg(1))
p [A.new, 1][1].send(:m, lg(2))
p $l
