# A `&.` String mutator statement over a variable calls the mutator the
# program defines on a reopened String, as a call: the statement form that
# changes the variable's String in place runs the builtin, and is only for
# a mutator nothing in the program defines.
class String
  def <<(x)
    concat("[#{x}]")
  end

  def upcase!
    replace("UP")
  end

  def slice!(*)
    "overridden"
  end
end

def mk(b) = b ? +"abc" : nil

s = mk(true)
s&.<<("x")
p s

u = mk(true)
w = u
u&.upcase!
p w

def f(v) = (v&.<<("y"); nil)
q = +"q"
f(q)
p q

t = mk(true)
t2 = t
t&.slice!(1)
p t2

n = mk(false)
n&.<<("z")
p n
