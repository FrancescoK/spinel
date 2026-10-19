# A rescue modifier whose value is a shared String and which a proc or a
# lambda answers boxed: the box is the String itself, so a change through
# the answer reaches the variable, as in CRuby. The answer was boxed as a
# copy of the String's bytes.
s = +"rr"
pr = proc { s rescue +"z" }
x = pr.call
x << "6"
p s, x.equal?(s)

s = +"rr"
lm = -> { s rescue +"z" }
x = lm.call
x << "7"
p s, x.equal?(s)

s = +"rr"
pr = proc { |q| Integer(q) rescue s }
x = pr.call("w")
x << "a"
p s, x.equal?(s)

s = +"rr"
pr = proc { |q| (q.size > 1 ? (s rescue +"y") : +"q") }
x = pr.call("w")
x << "b"
p s, x.equal?(s)
x = pr.call("ww")
x << "c"
p s, x.equal?(s)
