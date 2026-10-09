# spinel: gc-minor
# A boxed String's builtin conversion returns the same String.
values = [+"s", 1]
value = values[0]
text = value.to_s
text << "!"
p values[0], value, text
