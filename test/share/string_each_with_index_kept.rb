# s.each_char.with_index kept as an Enumerator reads the String when it is
# walked, as the each_char Enumerator under it does; so do the other String
# iterators' and an each_slice over one. Walked where it is made, the pair
# walk reads the String as it is there.

s = +"ab"
t = s
e = s.each_char.with_index
t << "d"
p e.to_a
class C
  attr_accessor :a
end
o = C.new
s = +"ab"
e = (o.a = s).each_char.with_index
s << "d"
p e.to_a, e.next
class W
  def a=(v)
    @a = v
  end
end
w = W.new
s = +"ab"
e = (w.a = s).each_char.with_index
s << "c"
p e.to_a
s = +"ab"
t = s
eb = s.each_byte.with_index
el = s.each_line.with_index
es = s.each_char.each_slice(1)
t << "\nd"
p eb.to_a.last, el.to_a, es.to_a
s = +"xy"
t = s
t << "z"
p s.each_char.with_index.to_a, s.each_char.with_index.map { |c, i| c * i }
s.each_char.with_index { |c, i| print c, i }
puts
