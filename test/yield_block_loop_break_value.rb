# A spliced block whose last statement is `loop { break v }`: the block's
# value is v (nil where no break has one). The statement form of the loop
# dropped it and left the splice void, and the C did not compile (#9258).
def q = yield
w = q { loop { break 1 } }
p w
x = q { loop { break +"ln" } }
x << "#"
p x
n = 0
y = q { loop { n += 1; break if n > 2 } }
p y, n
def r(v) = yield(v)
z = r(5) { |k| loop { break k * 2 } }
p z
