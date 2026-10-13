# A boxed index that is a Range on some calls and an Integer on others,
# reaching the index through a conditional or a method's value. The Range
# fact followed only direct writes, so the read and the store took the
# index as an Integer (TypeError), and a local only ever used as an index
# was narrowed to Integer, which stored a Range at index 0.
def pick(i) = i.odd? ? (0..1) : 0

def wide(i)
  return (1..) if i > 2
  i
end

def run(n)
  x = n.odd? ? 0..1 : 2
  m = [1, "x", 3]
  m[x] = 7
  p m
  a = [1, 2, 3]
  a[x] = 9
  p a
  y = x
  a[y] = 8
  p a

  z = pick(n)
  b = [10, 20, 30]
  p b[z]
  p "abcdef"[z]
  b[z] = 5
  p b
  p b[pick(n)]
  p [1.5, 2.5, 3.5][wide(n)]
end
run(1)
run(2)
run(3)
