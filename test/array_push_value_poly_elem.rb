# `x << v` and `x.push(v)` whose value is used (a method's last expression,
# an argument, an assignment) push a boxed nil into an Integer, Float or
# String array as that array's nil, as the statement form does. The value
# form converted it, so it went in as 0, 0.0 or "". (A value of another kind
# is refused as the statement form refuses it; see
# typed_array_store_refuses_foreign_kind.rb.)

def t
  yield
rescue => e
  e.class
end

def add(x) = x << {}[3]
a = [5, 6]
add(a)
p a, t { a.max }

def addf(x) = x << {}[3]
f = [1.5]
addf(f)
p f

def adds(x) = x.push({}[3])
s = ["b"]
adds(s)
p s

r = [7]
q = (r << {}[1])
p q, r.equal?(q)
