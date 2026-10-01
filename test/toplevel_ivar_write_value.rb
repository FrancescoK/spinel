# An ivar written as a value at the top level or in a top-level method
# (`def reset = (@n = 0)`, `p(@n = 5)`) lives on the Toplevel class. The
# value form did not look its slot up there, so a value went into a boxed
# slot unboxed and the C did not build: a slot that holds two kinds, and
# under --int-overflow=promote every Integer slot.
def reset = (@n = 0)
reset
p @n
def bump = (@n = @n + 1)
p bump
p(@n = 5)
x = (@m = 7)
p x
def once = (@k = (@k || 0) + 1) == 1
p once, once

def a = (@v = 1)
def b = (@v = "s")
p a
p b
p @v

def name! = (@s = "x")
p name!
def arr = (@a = [1, 2])
p arr
def fl = (@f = 1.5)
p fl
