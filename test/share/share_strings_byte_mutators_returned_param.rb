# --share-strings: append_as_bytes and bytesplice on the handle a method
# answers when it returns its parameter (`rec(s) = s`) change the caller's
# String in place, as every other String mutator does there; they had no arm
# for the handle and were refused. A nil the method can answer raises
# NoMethodError: the handle pickup now asks the method's nil fact, where it
# took a nil for an empty new String.
# spinel: gc-minor
def rec(s) = s
t = +"abc"
u = rec(t).append_as_bytes("x")
p u.equal?(t)
u << "z"
p t
rec(t).append_as_bytes("x").append_as_bytes(255, "y")
p t.bytesize
rec(t).append_as_bytes
rec(t).bytesplice(0, 1, "Z")
rec(t).bytesplice(1..2, "QQ")
p t[0, 6]
begin; rec(t).append_as_bytes(:sym); rescue => e; p e.class; end
begin; rec(t).bytesplice(100, 1, "Z"); rescue => e; p e.class; end
f = +"fr"
f.freeze
begin; rec(f).bytesplice(0, 1, "Z"); rescue => e; p e.class; end
begin; rec(f).append_as_bytes; rescue => e; p e.class; end
$n = 0
def counted(s) = ($n += 1; s)
w = +"ab"
counted(w).append_as_bytes("c", "d")
counted(w).bytesplice(0..1, "AB")
p w, $n
$g = +"glob"
rec($g).append_as_bytes("!")
p $g
e = +"é"
rec(e).append_as_bytes(0xC3, 0xA9)
p e, e.valid_encoding?, e.length
def maybe(f) = f ? +"x" : nil
begin; rec(maybe(false)).append_as_bytes("q"); rescue => e2; p e2.class; end
begin; rec(maybe(false)).bytesplice(0, 0, "q"); rescue => e2; p e2.class; end
begin; rec(maybe(false)) << "q"; rescue => e2; p e2.class; end
v = maybe(true)
rec(v).append_as_bytes("q")
p v
l = +""
200.times { |i| rec(l).append_as_bytes("x" * (i % 7), i % 200) }
1000.times { rec(l).bytesplice(0, 1, "yy") }
p l.bytesize
