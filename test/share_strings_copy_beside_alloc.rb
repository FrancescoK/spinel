# A read of a shared String slot is a fresh copy of its bytes, and nothing
# holds that copy until the call takes it. Beside another operand of the same
# call that allocates -- another such copy, a `+`, a `*` -- a collection there
# freed the copy and the call read freed bytes: CSV.generate_line quoted the
# empty field of ["", nil, 1.0] as six quotes, which parse back as a field of
# two. The copy is now held in a rooted temp across the other operands, and
# taken after them. gc-stress-test (the default build) and share-strings-test
# (the flag) run this file under SPINEL_GC_STRESS=2, which stops at the first
# freed read.
# spinel: gc-stress
require "csv"

p CSV.parse_line(CSV.generate_line(["", nil, 1.0]))

a = +"a-b"
b = +"-"
c = +"+"
all = [a, b, c]
a << "-c"
p all

# copies beside copies
p a.gsub(b, c)
p a.tr(b, c)
p a + b

# a copy beside an allocating argument
p a.gsub("-", "=" + "=")
p a.sub(b, c * 2)
p a.delete(b + "")

# a receiver read for its live bytes copies nothing
p a.center(9, b + c)
p a.count(b + c)
p a.index(b + c)
p [a.start_with?(b + ""), a.end_with?(c + "c"), a.include?(b * 1)]

# a user method's arguments
def join3(x, y, z)
  x + y + z
end
p join3(a, b, c)
p join3(a, b * 2, c)

# The callee sees the String as it is at the call: a copy is taken after the
# operands that run code, even one that appends to the same String.
def mut(s, t)
  s << t
  "abc"
end
x = +"x-y"
y = +"-"
z = +"+"
more = [x, y, z]
p join3(x, mut(x, "!"), z)
p join3(y, z, mut(y, "w"))
p "abc".delete(y, z, mut(y, "a"), mut(z, "a"))
p x.sub(y, mut(y, "z"))
p x + mut(x, "?") + y
p x.sub(y, (x << "!"; z))
p x.tr(y, (y << "a"; z))
p "#{x}#{(x << "Y"; y * 2)}#{x}"
p x.delete(z * 1, (x << "x"; "xyz"), (x << "y"; "xy"))
p more

# operands no binding took before: a write, a parenthesized statement, a begin
p a.tr(b, t = c * 2)
p a.sub(b, (c << "x"; "y"))
p a.sub(b, begin; c + c; end)
p a.sub(b, $g = c + c)

# a Hash key that is a copy is read after its value is built
h = {}
h[a] = b * 2
h.store(b, a * 2)
p h
p({ a => b * 2 })
p(h[c] = a * 2)

# replace copies from a fresh source after allocating its own copy
w = +"q"
w.replace(a + b)
p w
