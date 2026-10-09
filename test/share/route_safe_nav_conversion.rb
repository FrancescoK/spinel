# spinel: share
# spinel: gc-minor
# Under --share-strings, a method answering `s&.to_s` answers s itself, or
# nil for a nil s: the variable that takes the result changes the String the
# caller passed in.
def nullable_text(s) = s&.to_s
nullable_text(nil)
s = +"source"
t = nullable_text(s)
t << "!"
p s, t
