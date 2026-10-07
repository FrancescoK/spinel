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
  p g
end
value_position(ARGV.size)

# the lambda is made, and called after the mutation
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

# at top level
t = +"abcde"
u = t
$g = -> { t } if ARGV.length == 9123
t[0] = "X"
p t, u, $g
