# A String method of the program's own (here concat, reopened) answers what
# it answers, whether a block ends in it, a write keeps it, or an append
# chain runs through it; the builtin << beside it still answers its receiver.
class String
  def concat(*a)
    replace("C")
    "ret"
  end
end
def keep
  yield
end

buf = +"k"
v = keep { buf.concat("a") }
p v, buf
v2 = +"q"
w = keep { v2 << "z" }
w << "!"
p v2, w.equal?(v2)

b = +"b"
r = b.concat("x")
p r, b
c = +"c"
t = c
c << "z"
p t

d = +"d"
u = begin; d.concat("y"); end
p u, d
