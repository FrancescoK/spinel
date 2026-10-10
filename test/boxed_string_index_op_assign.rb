# `x[k] op= v` on a receiver only known at run time to be a String splices
# the String, as `x[k] = v` does: the store was dropped.
def pick(i)
  i == 0 ? +"abc" : [1, 2]
end

def key = 1

class Box
  def initialize(v)
    @v = v
  end

  def bump
    @v[0] += "I"
    @v
  end
end

x = pick(0)
x[0] += "Q"
p x
x["b"] += "R"
p x
x[/c/] *= 2
p x
x[-1] += "!"
p x
y = (x[2] += "T")
p y, x
z = (x[key] *= 2)
p z, x
p Box.new(pick(0)).bump

a = pick(1)
a[0] += 0.5
p a

s = pick(0).freeze
begin
  s[0] += "F"
rescue => e
  p e.class
end
