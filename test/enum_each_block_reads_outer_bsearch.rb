# The same `e.each { }` in a program that also makes a bsearch Enumerator:
# the block that reads the method's variables is a proc there, for the
# bsearch walk, and its captures are its own.

def calls(limit, e)
  n = 0
  r = e.each { |w| n += 1; w >= limit }
  [r, n]
end
p calls(2, [1, 2, 3].bsearch)
p calls(9, [1, 2, 3].bsearch)

def tagged(tag, e)
  seen = 0
  r = e.each { |w| seen += 1; p [tag, w] }
  [r.class, seen]
end
p tagged(:s, [1, 2, 3].each_slice(2))
