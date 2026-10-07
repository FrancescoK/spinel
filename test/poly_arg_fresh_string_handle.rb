# A fresh String stored through a receiver of more than one class: the value is
# an argument of a poly dispatch whose callee appends to it, so the parameter is
# the shared handle, and an expression that builds a plain String (`+""`, a dup,
# an interpolation, a builtin's result) is wrapped in one (#7833).
class Rec
  def []=(name, value)
  end
end

def store(params, name, kind)
  params[name] = store(params[name], name, kind) if name == "x"
  case kind
  when 0 then params[name] = +""
  when 1 then params[name] = "".dup
  when 2 then params[name] = String.new
  when 3 then params[name] = 42.to_s
  when 4 then params[name] = "a" + "b"
  when 5 then params[name] = "x#{name}"
  else params[name] = "abc".upcase
  end
end

7.times do |k|
  h = {}
  store(h, "a", k)
  p h
end
