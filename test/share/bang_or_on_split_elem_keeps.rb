# A bang on an element of a builtin's String Array held in a variable, with
# a new String on the other arm of `||`, is the element itself: the
# variable's Array was made of handles where it was written (#9258)
a = "ab cd".split.sort
w = a[0].upcase! || +"z"
w << "!"
p a, w
b = "AB cd".split
v = b[0].upcase! || +"z"
v << "!"
p b, v
def q = yield
c = "ef gh".split
x = q { c[1].upcase! }
x << "?" if x
p c, x
