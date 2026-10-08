# Flag-only: a method whose value is a variable's String on one path and nil
# on another (`begin; a; rescue; nil; end`, `return nil if f`, a bare
# `return`) answers the caller the String itself, so a change through the
# answer shows in the caller's variable, and nil where it answers nil, also
# after a read of another String on that path. A nil answer as a mutator's
# receiver raises NoMethodError.
def m(a) = (begin; a; rescue; nil; end)
s = +"ab"
m(s) << "x"
p s
r = m(s)
r << "y"
p s, r.equal?(s)
def g(a)
  begin
    raise "x" if a.size > 3
    a
  rescue
    nil
  end
end
q = +"q"
g(q).upcase!
p q
n = (g(q) << "w").size
p n, q
q << "long"
p g(q)
[-> { g(q).upcase! }, -> { p((g(q) << "z").size) }, -> { g(q) << "a" << "b" }].each do |f|
  begin
    f.call
  rescue NoMethodError => e
    p e.class
  end
end
def h(a) = (begin; a; rescue; nil; end)
t = +"t"
h(t) << "1" << "2"
p t
def k(a, f)
  puts a
  return if f
  a
end
v = +"v"
p k(v, true)
w = k(v, false)
w << "!"
p v
def j(a, f)
  return nil if f
  a
end
x = j(v, false)
x << "?"
p v, j(v, true)
begin
  j(v, true) << "z"
rescue NoMethodError => e
  p e.class
end
# A begin with an else answers the else's value, never the body's: the
# body's tail need not be a String, also with an ensure.
SE = +"se"
def ge
  begin
    1
  rescue
    SE
  else
    SE
  end
end
def ge2
  begin
    1
  rescue
    SE
  else
    SE
  ensure
    2
  end
end
ge << "1"
ge2 << "2"
p SE
re = ge
re << "3"
p SE, re.equal?(SE)
