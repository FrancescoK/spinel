# A typed array passed to a general-Array parameter the method mutates, where
# the binding cannot follow the argument back to where it is built: a Struct
# member keeps the array its constructor was handed. The conversion into the
# parameter is a copy, so the append would not reach `src` (CRuby prints
# [1, 2, "z"] twice); refused at compile time (#4480).
Box = Struct.new(:a)
def add(out) = out << "z"
src = [1, 2]
x = Box.new(src).a
add(x)
p src, x
