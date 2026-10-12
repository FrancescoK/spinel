# `s = (S = +"ab")` binds s to the String S holds, so `s << "c"` changes S
# (CRuby prints "abc"). A String constant's value form would hand back a
# copy; refused, not answered wrongly.
s = (S = +"ab")
s << "c"
p S
