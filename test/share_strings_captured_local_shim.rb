# A String local that a proc captures lives in a cell (a capture field
# inside the proc), and the in-place mutators that rebuild the String
# (`[]=`, insert, slice!, clear, setbyte) on such a local, held as the
# shared handle, read the handle as `lv_<name>` and the shadow they work
# on as the cell: neither is declared, so the C did not compile. Flag off,
# an alias makes the local the handle; under --share-strings every
# mutated local is one.

def statement_position(n)
  t = +"abcde"
  u = t
  g = -> { t } if n == 9123
  t[0] = "X"
  t.insert(1, "-")
  t.slice!(2)
  t.setbyte(2, 67)
  p t, u
  p g
end
statement_position(ARGV.size)

def value_position(n)
  t = +"hello"
  u = t
  g = -> { t } if n == 9123
  x = (t[0] = "J")
  y = t.insert(5, "!")
  z = t.slice!(0)
  w = t.setbyte(0, 69)
  p x, y, z, w, t, u
  e = t.clear
  p e, t, u
  p g
end
value_position(ARGV.size)

# the lambda is made before the mutation, and called after it
def called_later
  t = +"abc"
  u = t
  g = -> { t }
  t[1] = "B"
  t.clear
  t << "zz"
  p g.call, u
end
called_later

# the mutation inside the lambda's body reaches the local outside
def inside_lambda
  t = +"abcde"
  u = t
  g = -> { t[0] = "Y"; t.setbyte(1, 67); v = t.insert(0, ">"); v }
  p g.call
  p t, u
end
inside_lambda

# a mutation inside the mutator's own argument reads the same shadow
def nested_in_argument
  s = +"hello"
  v = s
  g = -> { s }
  s[0] = (s.setbyte(1, 69); s.slice!(4); "J")
  p s, v, g.call
end
nested_in_argument

# a proc, a thread or a fiber made inside the mutator's own argument
# shares the local's cell while the shim works on its shadow
def proc_in_argument
  s = +"abcdef"
  u = s
  s[0] = -> { s.size.to_s }.call
  p s, u
  s.insert(0, proc { s[1] }.call)
  x = s.slice!(-> { s.size - 1 }.call)
  p s, u, x
  g = nil
  s[1] = (g = -> { s }; "Z")
  s.setbyte(0, 60 + -> { s.size }.call)
  p s, u, g.call
  s[0] = Thread.new { s.size.to_s }.value
  f = nil
  s[1] = (f = Fiber.new { Fiber.yield s.size.to_s; "q" }; f.resume)
  p s, u, f.resume
end
proc_in_argument

# the same through a method parameter, and a lambda that outlives the change
def param_proc_in_argument(s)
  u = s
  g = -> { s }
  s[0] = -> { s.size.to_s }.call
  s[1] = (h = -> { s.upcase }; h.call)
  p s, u
  e = s.clear
  p e, s, u, g.call
end
param_proc_in_argument(+"abcdef")

# at top level
t = +"abcde"
u = t
$g = -> { t } if ARGV.length == 9123
t[0] = "X"
p t, u, $g
