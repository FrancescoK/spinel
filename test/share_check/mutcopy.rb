# An in-place change through a copy of the bytes: the change has to be
# written to the String every name sees.
s = +"abc"
t = s
s.succ!
p s
p t
