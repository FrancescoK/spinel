# String(s) answers a String argument itself, so r is s. The answer was a
# copy and s stayed "abc": refused, not compiled wrong.
s = +"abc"
r = String(s)
r << "!"
p s
