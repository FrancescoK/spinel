# A String bang on a call that answers the shared handle (`pick(s).upcase!`
# with a method returning its parameter) answers that String, or nil. A
# String mutator on that answer (`pick(s).upcase!.downcase!`) read it as
# the bang's new bytes, a copy, so the second change never reached s, and
# the default build's refusal became a wrong answer once the statement
# took a `rescue`. Under --share-strings the answer is held as the handle,
# a nil one raising NoMethodError for the next call as in CRuby, and every
# mutator after it changes the String in place.
def pick(value, missing)
  return nil if missing
  value
end
def id(v) = v

s = +"ab"
r = pick(s, false).upcase!.downcase! rescue p($!.class)
p s, r
t = (pick(s, false).upcase! || s).downcase!
p s, t
pick(s, false).upcase!.downcase!
p s
pick(s, false).upcase!.downcase! rescue 1
p s
r = (pick(s, false).swapcase!.swapcase! rescue 1)
p s, r, r.equal?(s)
id(s).upcase!.downcase!.capitalize!.swapcase!
p s

# every kind of mutator after the bang
s = +"abca"
id(s).upcase!.insert(1, "-")
p s
id(s).downcase!.setbyte(0, 120)
p s
id(s).upcase!.slice!(0)
p s
id(s).swapcase!.slice!(1..2)
p s
s.replace("bcab")
id(s).upcase!.delete!("B")
p s
id(s).downcase![0] = "Z"
p s
id(s).upcase!.bytesplice(0, 1, "Q")
p s
id(s).downcase!.append_as_bytes("w", 65)
p s
id(s).upcase!.concat("1", "2")
p s
id(s).downcase! << "3"
p s
id(s).upcase!.prepend(">")
p s
id(s).downcase!.sub!("q", "k")
p s
id(s).upcase!.tr!("K", "j")
p s
id(s).downcase!.squeeze!
p s
id(s).swapcase!.replace("new")
p s
id(s).upcase!.clear
p s

# a bang after a call that answers its receiver
s = +"ab"
id(s).upcase!.concat("1").downcase!
p s
id(s).upcase!.insert(0, "<") << ">"
p s
id(s).downcase!.prepend("[").replace("q").upcase!
p s
y = [id(s).downcase!.concat("2")]
y[0] << "!"
p s

# the value of the chain is s itself
s = +"xy"
v = id(s).upcase!.concat("!")
p v, v.equal?(s)
w = id(s).downcase!.insert(0, "<")
p w, w.equal?(s)
x = id(s).upcase!.clear
p x, x.equal?(s)
a = [id(s.replace("mn")).upcase!.downcase!]
p a, a[0].equal?(s)
r = (id(s).swapcase!.swapcase! rescue 1)
p r, r.equal?(s)
z = (id(s).upcase![1] = "Q")
p s, z
t = id(s).downcase!.swapcase!
t << "?"
p s, t.equal?(s)

# a bang that changed nothing answers nil, on which the next call raises
s = +"AB"
begin
  id(s).upcase!.downcase!
rescue NoMethodError => e
  p e.message
end
begin
  pick(s, true).upcase!.downcase!
rescue NoMethodError => e
  p e.message
end
begin
  id(s).upcase!.clear
rescue NoMethodError => e
  p e.message
end
p s

# safe navigation answers nil for a nil receiver; gsub!/sub!'s block form,
# `+@`, equal? and freeze on the chain
s = +"ab"
id(s).upcase!&.downcase!
p s
id(s).downcase!&.upcase!
p s
id(s).upcase!&.downcase!
p s
s.replace("abca")
id(s).swapcase!.gsub!(/A/) { "w" }
p s
id(s).upcase!.sub!("W") { |m| m + m }
p s
id(s).downcase!.+@.upcase!
p s
p id(s).downcase!.equal?(s), s.equal?(id(s).upcase!.downcase!)
g = +"gh"
p id(g).upcase!.freeze.frozen?, g.frozen?, g
begin
  id(g).downcase!
rescue => e
  p e.class
end
h = +"hi"
begin
  id(h).upcase!.freeze.downcase!
rescue => e
  p e.class
end
p h, h.frozen?

# the chain runs once, whatever mutator takes it as its receiver, in a
# statement, beside a rescue modifier and as a value
$n = 0
def idc(v) = ($n += 1; v)
def arg = "x"
c = +"ab"
idc(c).upcase!.insert(0, arg)
idc(c).downcase!.concat(arg)
idc(c).upcase!.setbyte(0, 81)
idc(c).downcase![1] = arg
idc(c).upcase!.sub!("X", arg)
idc(c).downcase! << arg
idc(c).upcase!.prepend(arg)
idc(c).downcase!.slice!(0)
idc(c).upcase!.bytesplice(0, 1, arg)
idc(c).downcase!.append_as_bytes(arg)
idc(c).upcase!.gsub!(/X/) { "y" }
idc(c).downcase!.upcase!.insert(1, arg)
idc(c).downcase!.concat(arg) rescue 0
v = idc(c).upcase!.replace(arg + "z")
p c, v, $n
idc(c).upcase!.clear
p c, $n

# safe navigation after a held link answers nil for nil and holds the String
s = +"ab"
id(s).upcase!&.downcase!.capitalize!
p s
id(s).upcase!&.downcase!&.capitalize!
p s
id(s).swapcase!&.concat("x")&.downcase!
p s
p id(s).upcase!&.downcase!.equal?(s)
id(s).upcase!&.downcase!.freeze
p s.frozen?

# a gsub! block that changes the String through another name raises, as
# CRuby's string modified
m = +"abc"
begin
  id(m).upcase!.gsub!(/B/) { m << "!"; "x" }
rescue RuntimeError => e
  p e.message
end
p m

# safe navigation on the call that answers the handle; a nil it answers
# is the next link's NoMethodError, as in CRuby
def pick(v, m) = m ? nil : v
n = +"ab"
id(n)&.upcase!.downcase!.capitalize!
p n
pick(n, false)&.upcase!.concat("1")
p n
begin
  pick(n, true)&.upcase!.downcase!
rescue NoMethodError => e
  p e.message
end
r = id(n)&.swapcase!&.swapcase!
p r, r.equal?(n)

# freeze's value compared by identity is the String
q = +"qr"
p id(q).upcase!.freeze.equal?(q), q.frozen?
a = [id(+"kept").upcase!.freeze]
p a, a[0].frozen?

# a frozen String raises FrozenError at the first bang
f = "fr".dup.freeze
begin
  id(f).upcase!.downcase!
rescue => e
  p e.class
end
p f
