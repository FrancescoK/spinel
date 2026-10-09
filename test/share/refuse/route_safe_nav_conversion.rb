# spinel: not-cruby
# The observed nullable conversion still needs a boxed return route.
def nullable_text(s) = s&.to_s
nullable_text(nil)
s = +"source"
t = nullable_text(s)
t << "!"
p s, t
