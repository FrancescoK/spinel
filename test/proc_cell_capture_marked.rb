# A captured Proc rides in an sp_int cell -- an integer slot holding a
# collectable object. The capture's scan marked the CELL and nothing marked the
# proc, so a nested `proc { |v| two.call(v, v) }` called through freed memory
# once full cycles were frequent (#4077). Run it under SPINEL_GC_FULL_INTERVAL=1
# to see the difference; the shape is what matters here.
# spinel: gc-stress
# spinel: gc-minor
two = proc { |a, b| [a, b] }
nested = proc { |v| two.call(v, v) }

adder = proc { |a, b| a + b }
twice = proc { |n| adder.call(n, n) }
outer = proc { |n| twice.call(twice.call(n)) }

i = 0
while i < 200
  Array.new(2_000, i * 1.0)      # churn, so the collector actually runs
  GC.start if (i % 50).zero?
  i += 1
end

p nested.call(7)
p outer.call(3)

# the same shape one level deeper, and through a method
def drive(p1, n) = p1.call(n)

deep = proc { |n| nested.call(n) }
p drive(deep, 5)

# a proc captured by a proc captured by a proc
a1 = proc { |x| x * 2 }
a2 = proc { |x| a1.call(x) + 1 }
a3 = proc { |x| a2.call(x) * 10 }
GC.start
GC.start
p a3.call(4)
