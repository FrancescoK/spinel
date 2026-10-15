# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
S = Struct.new(:a)
s = +"abc"
st = S.new(nil)
x = (st.a = s)
x << "!"
p s, st.a, x.equal?(s), st.a.equal?(s)
