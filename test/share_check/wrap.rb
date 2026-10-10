# `s&.to_s` answers s itself: the result is the caller's String, and reading
# it as bytes into a new handle makes a second String.
def nullable_text(s) = s&.to_s
nullable_text(nil)
s = +"source"
t = nullable_text(s)
t << "!"
p s, t
