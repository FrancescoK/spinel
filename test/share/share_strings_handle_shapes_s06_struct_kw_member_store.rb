# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
S = Struct.new(:a, :b, keyword_init: true)
c = ARGV.size == 0
s = +"abc"
st = S.new(a: nil, b: nil)
st.a, st.b = s, (c ? s : +"q")
st.b << "!"
p s, st, st.b.equal?(s), st.a.equal?(s)
