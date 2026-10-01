# A nil stored through a slot that can share its array (a parameter) notes
# the array's run-time nil flag; a local that owns its array keeps the plain
# store, its static mark covering every name the array has.
H = {1 => 2}
def add(x, k)
  x << H[k]
  nil
end
own = [1]
own << H[9]
c = [5]
add(c, 9)
p own.size, c.size
