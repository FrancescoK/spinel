# A mutable String handed to `%` as a poly value is a shared handle, not a
# plain String: `%c` read only the plain tag and printed nothing for it,
# where CRuby prints the first character. The handle is read as its value
# for every conversion, as `%s` already did.
def fmt(spec, v)
  spec % v
end

s = +"abc"
s << "d"
box = [s, 1][0]
puts fmt("%c", box)
puts fmt("%-3c|", box)
puts fmt("%3c|", box)
puts fmt("%s", box)
puts fmt("%p", box)
puts fmt("%c", 0x3042)
puts fmt("%c", "zz")
n = +"12"
n << "3"
nb = [n, 1][0]
puts fmt("%d", nb)
puts fmt("%05d", nb)
puts fmt("%x", nb)
f = +"1.5"
f << "5"
fb = [f, 1][0]
puts fmt("%.1f", fb)
puts fmt("%e", fb)
puts "%c and %s" % [box, box]
s << "e"
puts fmt("%c", box), s
