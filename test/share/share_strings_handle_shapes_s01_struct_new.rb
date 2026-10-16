# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
S = Struct.new(:a, :b)
c = ARGV.size == 0
s = +"abc"
st = S.new(s, (c ? s : +"q"))
st.a << "!"
st.b << "?"
p s, st, st.a.equal?(s), st.b.equal?(s)
