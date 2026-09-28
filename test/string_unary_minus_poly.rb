# String#-@ on a String held in a poly slot answers its frozen, deduplicated
# form, as on a typed String; it was negated as an Integer and answered 0.
def i(str) = -str
p i("abc")
x = ["q", 1][0]
p(-x)
p((-x).frozen?)
p((-x).equal?(-"q"))
y = ["q", 3][1]
p(-y)
