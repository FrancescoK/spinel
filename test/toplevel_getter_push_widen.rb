# A push or an index write through a top-level getter of a top-level ivar
# (`def fs = @fs; fs << 2`) widens the ivar, as `@fs << 2` does.
@fs = [1.5]
def fs = @fs
fs << 2
p fs

@items = [1]
def items = @items
items << "s"
items.push(:t)
p items

@m = nil
def memo = (@m ||= [1.5])
memo << 2
p memo

@h = {a: 1}
def hh = @h
hh["k"] = "v"
p hh

@q = [1]
def q = @q
self.q << :s
p q

def add(x) = (fs << x)
add("f")
p fs
