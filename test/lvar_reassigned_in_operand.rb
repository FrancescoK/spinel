def go
  a = [1, 5]
  a = a + [(a = [2, 5]; 1), 5]
  p a
  b = [1, 5]
  x = (b = b - [(b = [2, 5]; 1)])
  p x, b
  c = [1, 2]
  c = c | [(c = [3]; 4)]
  p c
  d = [1, 2]
  d = d & [(d = [3]; 1), 2]
  p d
  e = [1, 2]
  p(e + [(e = [9]; 3)])
  p e
end
go

def in_blocks
  a = [1, 5]
  [1, 2].each { |x| a = a + [(a = [x, 5]; 1), 5] }
  p a
  b = [1, 5]
  x = [7].map { |y| b - [(b = [y]; 1)] }
  p x, b
end
in_blocks

def other_operators
  a = [1, 5]
  p a[(a = [7, 8]; 0)]
  h = {k: 1}
  p h == {k: (h = {z: 2}; 1)}
  v = [1, "x"]
  v = v + [(v = [:q]; 2)]
  p v
  q = [3, 1]
  p(q <=> [(q = [0]; 3), 1])
  s = "ab"
  s = s + (s = "zz"; "c")
  p s
end
other_operators
