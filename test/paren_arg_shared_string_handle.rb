# A variable holding a String shared with another name, handed to a method
# inside parentheses after another statement, `g2((n += 1; t), ...)`, is
# that String, as the bare variable is: the method's change shows through
# the other name, also where a later argument rebinds the variable.
def g2(a = nil, b = 1, *r) = (a << "!"; 0)
n = 0
t = +"T"; o2 = t
xs = [+"y"]
g2((n += 1; t), *xs, (t = +"t"; 9))
p o2, t

def h1(a) = a << "?"
u = +"U"; o3 = u
h1((n += 1; u))
p o3, n
