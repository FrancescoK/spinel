# A shared String that the tail of a block a method yields to (or `then`
# runs) answers through conditionals nested in parentheses six deep, then
# changed in place through the name the call's value is given. The handle
# face read the tail's arms to a depth of 16, and each parenthesis, statement
# list and `else` cost a level, so the tail was taken for bytes and the
# program refused as one that would hand on a copy.
def q = yield
def t1
  a = +"a"
  b = +"b"
  c = +"c"
  k = ARGV.size + 6
  r = q { (if k == 6 then a else (if k == 5 then c else (if k == 4 then b else (if k == 3 then a else (if k == 2 then c else (if k == 1 then b else c end) end) end) end) end) end) }
  r << "!"
  p a, b, c, r
end

def t2
  a = +"a"
  b = +"b"
  c = +"c"
  k = ARGV.size + 6
  r = a.then { (unless k != 6 then a else (unless k != 5 then c else (unless k != 4 then b else (unless k != 3 then a else (unless k != 2 then c else (unless k != 1 then b else c end) end) end) end) end) end) }
  r << "!"
  p a, b, c, r
end

def y2 = yield(1)
def t3
  a = +"a"
  b = +"b"
  c = +"c"
  k = ARGV.size + 6
  r = y2 { |z| (if k == 6 then a else (if k == 5 then c else (if k == 4 then b else (if k == 3 then a else (if k == 2 then c else (if k == 1 then b else c end) end) end) end) end) end) }
  r << "!"
  p a, b, c, r
end

t1
t2
t3
