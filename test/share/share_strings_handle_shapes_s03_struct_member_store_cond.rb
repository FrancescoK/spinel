# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
S = Struct.new(:a, :b)
c = ARGV.size == 0
s = +"abc"
st = S.new(nil, nil)
st.a = (c ? s : +"q")
st.b = s.then { |q| q }
st.a << "!"
p s, st.b, st.a.equal?(s), st.b.equal?(s)
