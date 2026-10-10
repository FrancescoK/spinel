# bytesplice, append_as_bytes, and concat or prepend with other than one
# argument answer their receiver, as `<<` and one-argument concat do. A
# result kept in a local, a global, an Array element or a method's return is
# the receiver's String: changing it changes the receiver, and the other way
# round. succ!, next! and scrub! always answer their receiver, so a method
# that returns one of them hands on the receiver's String too.
def patch(x) = x.bytesplice(0, 1, "Z")
def wide(x) = x.concat("1", "2")
def front(x) = x.prepend("a", "b")
def bytes(x) = x.append_as_bytes("c", "d")
def same(x) = x.concat
def succ_of(x) = x.succ!
def next_of(x) = x.next!
def scrub_of(x) = x.scrub!


# a local
s = +"ab"
r = s.concat("x", "y")
r << "!"
p s, r, r.equal?(s)
s << "?"
p r

s = +"ab"
r = s.concat
r << "!"
p s, r.equal?(s)

s = +"ab"
r = s.prepend
r << "!"
p s, r.equal?(s)

s = +"ab"
r = s.prepend("1", "2")
r << "!"
s << "?"
p s, r, r.equal?(s)

s = +"abc"
r = s.bytesplice(0, 1, "Z")
r << "!"
p s, r.equal?(s)

s = +"abc"
r = s.bytesplice(0..0, "YY")
s << "?"
p r, r.equal?(s)

s = +"ab"
r = s.append_as_bytes("c", "d")
r << "!"
p s, r.equal?(s)

# an Array element
s = +"ab"
a = [s.concat("x", "y")]
a[0] << "!"
p s, a, a[0].equal?(s)

s = +"ab"
a = []
a << s.prepend("p", "q")
a[0] << "!"
p s, a[0].equal?(s)

s = +"abc"
a = [s.bytesplice(0, 1, "Z")]
a[0] << "!"
p s, a[0].equal?(s)

s = +"ab"
a = [s.append_as_bytes("c", "d")]
a[0] << "!"
p s, a[0].equal?(s)

# a method's return
s = +"abc"
t = patch(s)
t << "!"
p s, t.equal?(s)

s = +"ab"
t = wide(s)
t << "!"
p s, t.equal?(s)

s = +"ab"
t = front(s)
t << "!"
p s, t.equal?(s)

s = +"ab"
t = bytes(s)
t << "!"
p s, t.equal?(s)

s = +"ab"
t = same(s)
t << "!"
p s, t.equal?(s)

s = +"ab"
t = succ_of(s)
t << "!"
p s, t.equal?(s)

s = +"ab"
t = next_of(s)
t << "!"
p s, t.equal?(s)

s = +"ab"
t = scrub_of(s)
t << "!"
s << "?"
p s, t, t.equal?(s)

# a chain
s = +"ab"
t = s.concat("x", "y").prepend("p", "q").concat("z", "w")
t << "!"
p s, t.equal?(s)

# a global
$g = +"ab"
r = $g.concat("x", "y")
r << "!"
p $g

# the one-argument forms
s = +"ab"
r = s.concat("x")
r << "!"
p s, r.equal?(s)

s = +"ab"
r = s.prepend("p")
r << "!"
p s, r.equal?(s)

s = +"ab"
r = s << "x"
r << "!"
p s, r.equal?(s)

# a frozen receiver
s = "ab".freeze
[-> { s.concat("x", "y") }, -> { s.concat }, -> { s.prepend("p", "q") }, -> { s.prepend },
 -> { s.bytesplice(0, 1, "Z") }, -> { s.append_as_bytes("c") }].each do |f|
  begin
    f.call
  rescue FrozenError => e
    puts e.class
  end
end
p s
