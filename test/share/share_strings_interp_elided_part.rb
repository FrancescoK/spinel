# spinel: gc-stress
# CRuby drops an empty literal after the one dynamic part of a String
# (`"#{x}\<newline>"`, `"#{x}#{""}"`), so the String is the part's own
# conversion: a String part is answered as it stands, without a call of its
# to_s. The interpolation builds a new String only when something else is in
# it. A method answering such a String while another name holds the part
# answers that one String. Only a part that is statically a String is read
# so: an object's or a boxed part's conversion, a yield, a literal (built
# afresh) and an interpolation that is itself a part of another (adjacent
# literals) keep being built. A String that is nil answers "".
class Box
  attr_reader :a
  def put(a) = @a = a
end
$d = +"ab"
def joined = "#{$d}\
"
def empty_tail(s) = "#{s}#{""}"
def two_empty(s) = "#{s}#{""}#{""}"
def multi(s) = "#{1; s}\
"
def wrap = "#{yield}\
"
def adjacent(s) = "#{s}\
" "tail"
def adjacent_empty(s) = "#{s}#{""}" "-x"
def wrapped(s)
  @z = "#{s}\
"
  @z
end
# a new String: something else is in it
def prefixed(s) = "a#{s}\
"
def tailed(s) = "#{s}#{nil}"
def lead_empty(s) = "\
#{s}"
def finish(label, r, held)
  r << "!"
  p [label, r, held, r.equal?(held)]
end
finish("joined", joined, $d)
s = +"c"
finish("tail", empty_tail(s), s)
s = +"d"
finish("two", two_empty(s), s)
s = +"e"
finish("multi", multi(s), s)
# a yield part and adjacent literals keep being built
w = wrap { +"f" }
w << "!"
p w
s = +"f"
s = +"f2"
p adjacent(s), adjacent_empty(s)
s = +"h"
b = Box.new; b.put(wrapped(s)); $d = b.a; s << "?"; p [b.a, s, b.a.equal?(s)]
s = +"i"
finish("prefixed", prefixed(s), s)
s = +"j"
finish("nil tail", tailed(s), s)
s = +"k"
finish("lead empty", lead_empty(s), s)

# a part that may be nil answers "", and a literal part is built afresh
def maybe(c, s) = "#{c ? s : nil}\
"
a = [+"y"]
p "#{a[3]}\
", maybe(false, +"z"), maybe(true, +"z")
lit = "#{"lit"}\
"
lit << "x"
p lit
