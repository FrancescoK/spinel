# spinel: int64
# A unary sign on a value whose class has no `+@` / `-@` raises
# NoMethodError, as CRuby does: a boxed nil, true, false or Symbol (they
# answered themselves, `-nil` 0), and a statically typed one, a container,
# a Range or a Time (they answered nil or did not build). A boxed object
# whose class defines `+@` or `-@` calls it; numbers and Strings keep their
# signs.
class V
  def +@ = "plus"
  def -@ = "minus"
end
def try
  p yield
rescue NoMethodError => e
  p e.message
end
xs = [1, "a", nil, V.new, 2.5, :s, true, false, 2**70, 1r]
xs.each do |n|
  try { +n }
  try { -n } unless n.is_a?(String)
end
v = V.new
p(+v, -v)
try { +true }
try { -false }
try { +:s }
try { +nil }
try { -nil }
a = [1]
try { +a }
try { +(1..2) }
try { +{ a: 1 } }
try { +Time.at(0) }
x = 5
f = 1.5
p(-x, +x, -f, -(2**70), +(1r), -(1 + 2i))
s = ARGV.size > 5 ? +"a" : nil
try { +s }
