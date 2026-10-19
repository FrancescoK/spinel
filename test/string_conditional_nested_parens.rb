# A shared String answered by conditionals nested in parentheses, four deep in
# a ternary chain or five in an `||` chain, then changed in place through the
# name that holds it (a local, an Array element, a `+=` copy, an attribute,
# an `upcase!` on the value). The arms were read to a depth of 16, and each
# parenthesis, statement list and `else` cost a level, so the program was
# refused as one that would hand on a copy.
def t1
  a = +"a"
  b = +"b"
  c = +"c"
  k = ARGV.size + 4
  r = (k == 4 ? b : (k == 3 ? a : (k == 2 ? c : (k == 1 ? b : c))))
  r << "!"
  p a, b, c, r
end

def t2
  a = +"a"
  b = +"b"
  c = +"c"
  k = ARGV.size + 4
  x = [(k == 4 ? b : (k == 3 ? a : (k == 2 ? c : (k == 1 ? b : c)))), 1]
  x[0] << "!"
  p a, b, c, x
end

def t3
  a = +"a"
  b = +"b"
  c = +"c"
  k = ARGV.size + 4
  r = (k == 4 ? b : (k == 3 ? a : (k == 2 ? c : (k == 1 ? b : c))))
  r += "?"
  r << "!"
  p a, b, c, r
end

class W; attr_accessor :v; end
def t4
  a = +"a"
  b = +"b"
  c = +"c"
  k = ARGV.size + 4
  w = W.new
  w.v = (k == 4 ? b : (k == 3 ? a : (k == 2 ? c : (k == 1 ? b : c))))
  w.v << "!"
  p a, b, c, w.v
end

def t5
  a = +"a"
  b = +"b"
  c = +"c"
  k = ARGV.size + 5
  r = ((nil || (nil || (nil || (nil || (nil || c)))))).upcase!
  p a, b, c, r
end

t1
t2
t3
t4
t5
