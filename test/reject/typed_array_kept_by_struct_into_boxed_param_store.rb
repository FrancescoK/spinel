# A typed array passed to a boxed parameter (its callers disagree on the
# array kind) that the method stores a String into, where the binding cannot
# follow the argument back to where it is built: a Struct member keeps the
# array its constructor was handed. The store would promote a copy `src`
# never sees (CRuby prints ["s", 2] twice); refused at compile time.
Box = Struct.new(:a)
def m(arr); arr[0] = "s"; end
m(["x"])
src = [1, 2]
x = Box.new(src).a
m(x)
p src, x
