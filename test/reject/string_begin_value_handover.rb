# A begin block's value is its last expression, here s itself, so x is s.
# x held a copy and missed the append: refused, not compiled wrong.
s = +"abc"
x = begin; s; rescue; nil; end
s << "!"
p x
