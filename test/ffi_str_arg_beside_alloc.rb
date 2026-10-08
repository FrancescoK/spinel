# spinel: not-cruby -- ffi_func is Spinel's own; the answers are libc's.
# A String held as an sp_String * handle is handed to a :str argument as a
# copy when another argument of the call runs code. That copy, like a
# String a call just answered, is held by nothing but the C call's argument
# list, so the argument beside it must not collect it while it is made:
# two handles, a handle beside a call that builds a String, a handle beside
# an Integer argument that allocates on its way, the same among the
# arguments of a variadic function, and a handle beside a call on a boxed
# receiver: a reader in the program's class, a builder where the box holds
# a String. A reader on an element of an Array of one class's objects
# builds nothing, and its call keeps its C.
module LibC
  ffi_func :strncmp, [:str, :str, :int], :int
  ffi_func :printf, [:str, :varargs], :int
end

def joined(a, b) = a + b
def width(v) = [v, v, v].size + 2

class Named
  def initialize(n); @name = n; end
  def dup; @name; end
  def get; @name; end
end

s = +"12"
t = s
t << "345"
x = "12"

p LibC.strncmp(s, t, s.size + 0) <=> 0
p LibC.strncmp(s, joined(x, "345"), 5) <=> 0
p LibC.strncmp(joined(x, "345"), s, 5) <=> 0
p LibC.strncmp(joined(x, "345"), joined(x, "346"), 5) <=> 0
p LibC.strncmp(s, "12345", width(1)) <=> 0
p LibC.strncmp("12345", s, width(1)) <=> 0
r = [Named.new(joined(x, "345")), joined(x, "345")]
i = 1
p LibC.strncmp(s, r[i].dup, 5) <=> 0
p LibC.strncmp(s, r[i - 1].dup, 5) <=> 0
q = [Named.new(joined(x, "345")), Named.new(joined(x, "346"))]
p LibC.strncmp(s, q[i - 1].get, 5) <=> 0
p LibC.strncmp(s, q[i].get, 5) <=> 0
LibC.printf("%s %s\n", s, joined(x, "345"))
LibC.printf("%s %s\n", joined(x, "345"), s)
