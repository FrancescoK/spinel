# A proc answers its body's value, here s itself. The answer was a copy and
# s stayed "abc": refused, not compiled wrong.
s = +"abc"
pr = proc { s }
pr.call << "?"
p s
