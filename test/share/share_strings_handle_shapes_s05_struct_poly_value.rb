# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
class PA; def pick(t) = t; end
class PB; def pick(t) = t.dup; end
S = Struct.new(:a)
px = ARGV.size == 0 ? PA.new : PB.new
s = +"abc"
st = S.new(nil)
st.a = px.pick(s)
st.a << "!"
p s, st.a.equal?(s)
