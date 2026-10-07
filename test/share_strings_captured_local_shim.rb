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

# an inlined method inside the argument, with a local of the receiver's own
# name that its own lambda or fiber captures: not the receiver's slot
def yield_lambda(n)
  s = "h#{n}"
  f = -> { s + "!" }
  yield f.call
end

def yield_fiber(n)
  s = "k#{n}"
  f = Fiber.new { Fiber.yield s + "?" }
  yield f.resume.to_s
end

def inlined_same_name
  s = +"abcdef"
  u = s
  g = -> { s }
  s[0] = (r = +""; yield_lambda(1) { |v| r << v }; r)
  s[1] = (r = +""; yield_fiber(2) { |v| r << v }; r)
  p s, u, g.call
end
inlined_same_name

# the argument changes the String through the captured cell, with a shim of
# its own inside a lambda: the shim reads the String after the argument ran,
# so the change is kept, and the later shims see the local as before
def cell_change_in_argument
  s = +"abcdef"
  u = s
  f = -> { s[2] = "Z"; "6" }
  s[0] = s[4]
  s[1] = f.call
  p s, u
  s[0] = (g = -> { s[3] = "W"; s.size.to_s }; g.call)
  p s, u
  s.insert(0, (h = -> { s[2] = "Y"; "I" }; h.call))
  s[1] = (k = -> { s.size.to_s }; k.call)
  p s, u
  s[0, 2] = (m = -> { s[3] = "V"; "T" }; m.call)
  s.slice!((q = -> { s.insert(1, "Q"); 0 }; q.call))
  s[1] = (r = -> { s[0] }; r.call)
  p s, u
end
cell_change_in_argument

# a lambda in the argument that runs nothing there is made while the shim
# works on its shadow, and still captures the local's cell
def lambda_left_in_argument
  s = +"abcdef"
  u = s
  s[0] = (-> { s }; "Z")
  s.insert(1, (proc { s }; "W"))
  p s, u
end
lambda_left_in_argument

# setbyte runs its index, then its byte, and only then checks that the
# String is not frozen; freezing the captured local freezes the handle
def setbyte_order(n)
  s = +"abc"
  u = s
  g = -> { s } if n == 9123
  byte = 65
  s.setbyte((byte = 66; 0), byte)
  p s, u
  s.freeze
  k = 0
  begin
    s.setbyte((k += 1; 1), (k += 10; 67))
  rescue FrozenError => e
    p e.class
  end
  p k, s, u.frozen?
end
setbyte_order(ARGV.size)

# at top level
t = +"abcde"
u = t
$g = -> { t } if ARGV.length == 9123
t[0] = "X"
p t, u, $g
