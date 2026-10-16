# A yielding method spliced at its call hands its result slot the String
# each path answers: a `return` of a constant or of its argument, a
# conditional's arms, a new String. A change through the variable the
# call's value is written to reaches that String.
K = +"const"
def m(x)
  return K if x.size > 2
  yield x
  +"tail"
end
def pick(x, k)
  yield x
  k ? x : +"new"
end
def arg(x)
  return x if x.start_with?("a")
  return if x.empty?
  yield x
  +"other"
end
r = m(+"abc") { |v| v.size }
r << "2"
p r, K
r = m(+"zz") { |v| v.size }
r << "3"
p r, K
s = +"held"
t = pick(s, true) { |v| v.size }
t << "!"
p s, t, t.equal?(s)
u = pick(s, false) { |v| v.size }
u << "?"
p s, u
a = +"abc"
w = arg(a) { |v| v.size }
w << "+"
p a, w.equal?(a)
p arg(+"") { |v| v }
z = arg(+"q") { |v| v.size }
z << "-"
p z
