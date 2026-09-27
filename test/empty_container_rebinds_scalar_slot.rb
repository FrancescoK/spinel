# An empty `{}` (or `[]`) written into a slot whose other writes are a
# scalar or an object has no type of its own yet, and the slot kept the
# other type: the C assigned the hash pointer to an sp_int (or a double, a
# const char *). The slot holds both, so it is boxed.

x = 1
p x
x = {}
p x

s = "s"
p s
s = {}
p s

f = 1.5
p f
f = {}
p f.empty?

sym = :a
p sym
sym = {}
p sym

r = {}
p r
r = 1
p r

w = 1
p w
w = {}
w[:a] = 1
w["b"] = 2
p w

@iv = 1
p @iv
@iv = {}
p @iv

@ia = 1
p @ia
@ia = []
p @ia

$g = 1
p $g
$g = {}
p $g

class Box
  attr_accessor :v
end
b = Box.new
b.v = 1
p b.v
b.v = {}
p b.v

def tail_empty(b)
  return 1 if b
  {}
end
p tail_empty(true)
p tail_empty(false)

def return_empty(b)
  return {} unless b
  2
end
p return_empty(true)
p return_empty(false)
