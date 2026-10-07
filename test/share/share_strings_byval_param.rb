# A method the default build cannot lend a String parameter's slot to
# passes the parameter by value: an aliased method (the alias's call sites
# keep the plain ABI), a Struct class's method, and a method sharing its
# name with one of those. Its appends to the parameter must still reach the
# caller's String, so the share rule shares the parameter with the
# arguments instead of lending it.
def add_field(line, v)
  line << ","
  line << v
  nil
end
alias add_field2 add_field
line = +"a"
add_field2(line, "q")
add_field(line, "r")
p line

def grow(s)
  s << "a"; s << "b"; nil
end
alias grow2 grow
t = +"t"
grow(t)
p t

Pair = Struct.new(:a) do
  def add(s)
    s << "a"; s << "b"
    nil
  end
end
u = +"u"
Pair.new(1).add(u)
p u

Cell = Struct.new(:a) do
  def put(s)
    s << "z"
    nil
  end
end
class Box
  def put(s)
    s << "a"; s << "b"; nil
  end
end
v = +"v"
Box.new.put(v)
p v
w = +"w"
Cell.new(1).put(w)
p w
