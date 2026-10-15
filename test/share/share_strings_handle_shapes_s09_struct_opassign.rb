# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
S = Struct.new(:a)
s = +"abc"
st = S.new(nil)
st.a ||= s
st.a << "!"
p s, st.a.equal?(s)
