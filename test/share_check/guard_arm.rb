# `s&.to_s` answers s itself when it is a String. The arm for a box that
# holds no shared handle wraps the conversion of a value that is no String
# the rule shares: it declares itself, and the check reports nothing here.
def nullable_text(s) = s&.to_s
nullable_text(nil)
s = +"source"
t = nullable_text(s)
t << "!"
p s, t
