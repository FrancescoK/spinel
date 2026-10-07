# A method that appends to a String parameter and returns it, called where
# its value is dropped -- a statement, the tail of a block its iterator
# ignores (each_with_index, times, select, a method whose yield is a
# statement), a loop body's tail -- hands that value to nobody, so the
# parameter stays lent as if the method returned nil. A `<<` chain on a
# variable (`line << a << b`) mutates that variable's own String. A caller
# that does read the value, or a second name for the String, still shares
# it: each change shows through every name.
def add_field(line, v)
  line << "," << v
  line
end

# the same method, called where its value is read
def add_read(line, v)
  line << "," << v
  line
end

def twice
  yield 1
  yield 2
  nil
end

# dropped values: a statement, block tails, a loop body's tail
line = +"a"
add_field(line, "x")
[1, 2].each_with_index { |v, i| add_field(line, i.to_s) }
3.times { |i| add_field(line, i.to_s) }
[5].select { |v| add_field(line, v.to_s) }
twice { |v| add_field(line, v.to_s) }
i = 0
while i < 2
  add_field(line, "w")
  i += 1
end
p line

# the benchmark's shape: rows built in a helper, kept and changed later
def build_row(fields)
  row = +""
  fields.each_with_index { |f, k| add_field(row, f) }
  row
end
rows = []
2.times { |k| rows << build_row(["r", k.to_s]) }
rows.each { |r| r << ";" }
p rows

# chains on a variable, a parameter and an ivar, and through a bang
s = +"s"
s << "b" << "c"
p s
def grow(buf)
  buf << "1" << "2"
  nil
end
g = +"g"
grow(g)
p g
@iv = +"i"
@iv << "j" << "k"
p @iv
t = +" t "
t.strip! << "!"
p t

# read values and second names: these still share
l1 = +"a"
r = add_read(l1, "x")
r << "!"
p l1
l2 = +"a"
r2 = send(:add_read, l2, "s")
r2 << "!"
p l2
l3 = +"a"
x3 = [1].each_with_index.map { |v, k| add_read(l3, k.to_s) }
x3[0] << "!"
p l3
l4 = +"a"
other = l4
add_field(l4, "x")
[1].each { |v| add_field(l4, v.to_s) }
p other
l5 = +"a"
kept = [l5]
twice { |v| add_field(l5, "q") }
p kept

# a chain whose head is no variable: a reader's answer, an element, a
# method's answer
class Holder
  def initialize; @s = +"h"; end
  def s; @s; end
end
o = Holder.new
o.s << "x" << "y"
p o.s
arr = [+"e"]
arr[0] << "x" << "y"
p arr
def same(h) = h
h = +"h"
same(h) << "a" << "b"
p h

# a method the default build passes its parameter by value -- an aliased
# one, a Struct's, one sharing its name with a Struct's -- is not lent its
# argument's slot, so its appends still reach the caller's String through
# the shared handle, chained, returned and dropped alike
def al_ret(line, v)
  line << "," << v
  line
end
alias al_ret2 al_ret
a1 = +"a"
al_ret2(a1, "q")
al_ret(a1, "r")
p a1
def al_nil(line, v)
  line << "," << v
  nil
end
alias al_nil2 al_nil
a2 = +"a"
al_nil2(a2, "q")
al_nil(a2, "r")
p a2
def al_split(s)
  s << "a"; s << "b"; s
end
alias al_split2 al_split
a3 = +"t"
al_split(a3)
p a3
def al_chain(s)
  s << "a" << "b"; nil
end
alias al_chain2 al_chain
a4 = +"t"
al_chain(a4)
p a4
Rec = Struct.new(:a) do
  def add(s)
    s << "a" << "b"
    nil
  end
  def mix(s)
    s << "z"
    nil
  end
  def mix2(s)
    s << "z"
    nil
  end
end
a5 = +"t"
Rec.new(1).add(a5)
p a5
class Mixer
  def mix(s)
    s << "a" << "b"; nil
  end
  def mix2(s)
    s << "a"; s << "b"; s
  end
end
a6 = +"t"
Mixer.new.mix(a6)
p a6
a7 = +"t"
Mixer.new.mix2(a7)
p a7
a8 = +"u"
Rec.new(1).mix(a8)
Rec.new(1).mix2(a8)
p a8

# a String a memoizing reader answers reaches a helper as the default
# build's temporary copy, so a parameter that appends to it shares it with
# the reader's ivar instead of being lent: chained, returned and dropped,
# through a block's tail, and handed on to another helper
def memo_chain(line, v)
  line << "," << v
  nil
end
def memo_drop(line, v)
  line << v
  line
end
def memo_split(line, v)
  line << ","
  line << v
  nil
end
def memo_inner(l)
  l << "x"
  nil
end
def memo_outer(l)
  memo_inner(l)
  nil
end
def m_src; @m_src ||= +"a"; end
memo_chain(m_src, "x")
memo_drop(m_src, "y")
memo_split(m_src, "z")
memo_outer(m_src)
p m_src
def m_src2; @m_src2 = +"b" unless @m_src2; @m_src2; end
memo_chain(m_src2, "x")
p m_src2
class Page
  def initialize; @b = +"<"; end
  def body; @b ||= +"z"; end
  def build(fs) = (fs.each_with_index { |f, i| memo_drop(body, f) }; body)
end
p Page.new.build(["a", "b"])
