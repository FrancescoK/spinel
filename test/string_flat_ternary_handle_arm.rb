# A value-position `if` in its flat form whose result is a String's bytes,
# with an arm that is a String handle beside nil's bytes arm (`(s ? s :
# nil) || :done`): the C conditional became a void *, read through as
# bytes, and the program printed garbage.
s = ARGV.empty? ? "x" : nil
h = { k: (s ? s : nil) || :done }
p h
t = ARGV.empty? ? nil : "y"
h2 = { k: (t ? t : nil) || :done }
p h2
u = +"u"
v = (u.empty? ? nil : u) || "w"
v << "!"
p u
