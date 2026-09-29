# A multiple assignment from an empty array literal answers that empty array
# wherever its value is used.
x = (a, b = [])
p x, a, b

def m1 = (c, d = [])
p m1

def m2
  e, f = []
end
p m2

p((g, h = []))
y = (i, *j = [])
p y, i, j
p [(k, l = []), 1]
