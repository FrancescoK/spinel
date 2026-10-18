# bytesplice answers its receiver, so patch hands back the caller's String
# and t is s itself. The result is a copy today, so an append through t
# would not reach s (CRuby "Zbc!", Spinel "Zbc"): refused, as a method
# returning `x.strip!` is.
def patch(x) = x.bytesplice(0, 1, "Z")
s = +"abc"
t = patch(s)
t << "!"
p s
