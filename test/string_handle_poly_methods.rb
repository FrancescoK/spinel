# String methods on a shared String handle (#6179) held in a poly slot: an
# Array or Hash element a method appended to, or a parameter that also
# takes an Integer. bytesize, ord, getbyte, to_c, =~ and !~ tested the
# plain String box alone, and setbyte and slice! on an element read had
# no way to hand the new contents back to the handle; each raised
# NoMethodError for the String.

def app(x) = x << "!"

arr = [+"héllo"]
app(arr[0])
p arr[0].bytesize, arr[0].ord, arr[0].getbyte(1), arr[0].getbyte(-1), arr[0].getbyte(9)
p(arr[0] =~ /l+/, $~[0], arr[0] =~ /z/)
p(arr[0] !~ /l/, arr[0] !~ /z/)
p arr[0].to_c
re = Regexp.new("o!")
p(arr[0] =~ re)

arr[0].setbyte(0, 72)
p arr[0]
p arr[0].slice!(1)
p arr[0].slice!(0, 2)
p arr[0].slice!(/o/)
p arr[0].slice!("!")
p arr[0].slice!(5)
p arr[0]

h = { k: +"3+4i" }
app(h[:k])
p h[:k].to_c, h[:k].bytesize
h[:k].setbyte(0, 53)
p h[:k].slice!(1..2), h[:k]

# a parameter that is a String here and an Integer there
def probe(v)
  v << "?" if v.is_a?(String)
  [v.bytesize, v.ord, v.getbyte(0), v =~ /b/]
end
p probe(+"ab")
p(probe(7)) rescue p $!.class

# a frozen handle still refuses the write
fz = [+"xy"]
app(fz[0])
fz[0].freeze
begin; fz[0].setbyte(0, 65); rescue FrozenError => e; p e.class; end
begin; fz[0].slice!(0); rescue FrozenError => e; p e.class; end
p fz[0]

# a proc parameter is the handle too; a frozen one refuses setbyte before
# writing the byte
pr = proc { |t| t << "!"; t.freeze; begin; t.setbyte(0, 65); rescue FrozenError => e; p e.class; end; t }
q = +"pq"
p pr.call(q), q
