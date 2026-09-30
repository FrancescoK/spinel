# The snapshot is hand-written: CRuby's Array holds every value, so it cannot come from reference Ruby.
# A value whose kind is decided at run time, stored into a typed array, is
# refused with TypeError rather than coerced to the element kind: "z".to_i
# into an Integer array used to store 0 and say nothing (#4481). nil is the
# kind's own nil, an Integer is promoted into a Float array. Every store
# route answers the same way, the typed-array Method adapter included.
def try(label)
  yield
rescue TypeError => e
  puts "#{label}: TypeError: #{e.message}"
end
# the boxed dispatch (out is a general slot: the call sites disagree). An
# array built where the call can follow it, a method's value too, widens
# with the parameter and holds what CRuby's does.
def collect(out, src)
  i = 0
  while i < src.length
    out << src[i]
    i += 1
  end
end
a = Array.new(0, 0);    try("int<<str")   { collect(a, [1, "z"]) };    p a
b = Array.new(0, 0);    try("int<<float") { collect(b, [1, 2.5]) };    p b
c = Array.new(0, 0.0);  try("flt<<str")   { collect(c, [1.5, "z"]) };  p c
c2 = Array.new(0, 0.0); try("flt<<int")   { collect(c2, [1.5, 2]) };   p c2
d = Array.new(0, "");   try("str<<int")   { collect(d, ["a", 7]) };    p d
def ints = Array.new(0, 0)
a2 = ints;              try("int<<str held") { collect(a2, [1, "z"]) }; p a2
d2 = Array.new(0, "");  try("str<<nil")   { collect(d2, ["a", nil]) }; p d2
# the static stores (out is the typed array itself)
def set_first(out, src) = out[0] = src[1]
e = Array.new(2, 0); try("[]=") { set_first(e, [1, "z"]) }; p e
e2 = Array.new(2, 0); try("[]= nil") { set_first(e2, [1, nil]) }; p e2
def push_second(out, src)
  out.push(src[1])
  out << src[1]
end
f = Array.new(0, 0); try("push") { push_second(f, [1, "z"]) }; p f
f2 = Array.new(0, 0); try("push int") { push_second(f2, [1, 2]) }; p f2
def unshift_second(out, src) = out.unshift(src[1])
g = Array.new(0, 0); try("unshift") { unshift_second(g, [1, "z"]) }; p g
def insert_second(out, src) = out.insert(0, src[1])
h = Array.new(0, 0); try("insert") { insert_second(h, [1, "z"]) }; p h
def cat(out, src) = out.concat(src)
k = Array.new(0, 0); try("concat") { cat(k, [1, "z"]) }; p k
def fill_second(out, src) = out.fill(src[1])
m = Array.new(2, 0); try("fill") { fill_second(m, [1, "z"]) }; p m
# the adapter
n = [1, 2]
try("method push") { n.method(:push).call("z") }; p n
try("method push int") { n.method(:push).call(3) }; p n
