# A bang the block of transform_values! or transform_values answers on its
# value stores the receiver's own String (upcase! answers self when it
# changes the String), as CRuby does: a change through the hash's value
# reaches the String the value was. The block's answer was boxed as the
# bytes of the expression instead of as the receiver's box.
s = +"ab"
h = { k: s }
h.transform_values!(&:upcase!)
h[:k] << "!"
p s, h[:k].equal?(s)

u = +"ef"
j = { k: u }.transform_values { |v| v.upcase! }
j[:k] << "#"
p u, j[:k].equal?(u)

t = +"cd"
g = { k: t, n: 1 }.transform_values { |v| v.is_a?(String) ? v : v.to_s }
g[:k] << "?"
p t, g[:k].equal?(t)

w = +"gh"
x = { k: w }.transform_values! { |v| v.upcase! || v }
x[:k] << "%"
p w, x[:k].equal?(w)

# a conversion of the value: to_s and String(v) answer a String itself, and
# a number's to_s is a new String
s = +"ab"
h = { k: s, n: 1 }
r = h.transform_values { |v| v.to_s }
r[:k] << "#"
p s, r[:k].equal?(s), r[:n]

q = h.transform_values { |v| String(v) }
q[:k] << "$"
p s, q[:k].equal?(s), q[:n]

a = h
r3 = a.transform_values { |v| v.to_s }
r3[:k] << "%"
p s, r3[:k].equal?(s)

h.transform_values! { |v| v.to_s }
h[:k] << "&"
p s, h[:k].equal?(s), h[:n]

class Holder
  def initialize(s) = @h = { k: s, n: 2 }
  def go = @h.transform_values { |v| v.to_s }
  def hash = @h
end
t = +"cd"
ho = Holder.new(t)
o = ho.go
o[:k] << "!"
p t, o[:k].equal?(t), o[:n]
