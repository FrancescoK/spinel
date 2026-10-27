# A Range literal with boxed ends, assigned to a local that is then passed
# to a call on an Array that does not index with it (push, include?,
# index), stays the Range CRuby makes: a String Range here. Only a local
# that indexes an Array or a String (`a[r]`, slice, byteslice) takes the
# Integer representation, whose ends must be Integers.
mixed = ["a", "c", 1, 3]

r = mixed[0]..mixed[1]
list = []
list.push(r)
p list
p r.to_a

s = mixed[0]..mixed[1]
p [s].include?(s)
p [1, s].index(s)

i = mixed[2]..mixed[3]
p [10, 20, 30, 40][i]
