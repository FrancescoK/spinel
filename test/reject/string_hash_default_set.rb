# `h.default = s` makes s itself what a missing key reads, so the append
# changes s. It appended to a copy and s stayed "abc": refused, not
# compiled wrong.
s = +"abc"
h = {}
h.default = s
h[:missing] << "!"
p s
