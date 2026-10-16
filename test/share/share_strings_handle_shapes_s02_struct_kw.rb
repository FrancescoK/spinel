# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
S = Struct.new(:a, :b, keyword_init: true)
c = ARGV.size == 0
s = +"abc"
st = S.new(a: s, b: (c ? s : +"q"))
st.b << "!"
p s, st.a, st.b.equal?(s)
