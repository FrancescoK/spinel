# Unary + answers an unfrozen String itself, so the append changes s. It
# appended to a copy and s stayed "abc": refused, not compiled wrong.
s = +"abc"
(+s) << "!"
p s
