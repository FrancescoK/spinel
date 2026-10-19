# A rescue modifier whose value is a shared String and which a proc, a
# lambda or the block of a String reopening's yielding method answers
# boxed: the box is the String itself, so a change through the answer
# reaches the variable, as in CRuby. The answer of a proc and a lambda was
# boxed as a copy of the String's bytes; the block of the reopening was
# refused.
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

class String
  def pm(a) = yield(a)
end

s = +"rr"
r = "a".pm(s) { |v| v rescue +"z" }
r << "2"
p s, r.equal?(s)

s = +"rr"
r = "a".pm(s) { |v| Integer("q").to_s rescue v }
r << "3"
p s, r.equal?(s)

s = +"rr"
r = "a".pm(s) { |v| (v.size > 0 ? v : +"n") rescue +"z" }
r << "4"
p s, r.equal?(s)

s = +"rr"
r = "a".pm(s) { |v| next (v rescue +"z") if v.size > 1; v }
r << "5"
p s, r.equal?(s)

s = +"rr"
r = "a".pm(s) { |v| v.size > 1 ? (v rescue +"z") : +"q" }
r << "6"
p s, r.equal?(s)
