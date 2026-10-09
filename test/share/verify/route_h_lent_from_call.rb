def grow(b) = (b << "x"; b.size)
def mk = (@m ||= +"abc")
grow(mk)
p @m
