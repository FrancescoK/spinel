# spinel: gc-minor
# Construction selects each definition's function, defaults, and arity.
class CaptureDefaults
  def answer = 2
end
def bound_default(d) = d.method(:answer)
def default_metadata(d)
  m = d.method(:answer)
  p m.arity, m.parameters, m.owner.name, m.original_name
  p m.source_location[1]
end
def unbound_default(d) = CaptureDefaults.instance_method(:answer).bind(d)
def invoke_default(d) = CaptureDefaults.instance_method(:answer).bind_call(d)
d = CaptureDefaults.new
before = bound_default(d)
default_metadata(d)
u = unbound_default(d)
p invoke_default(d)
class CaptureDefaults
  def answer(x = 3, y = 4) = x + y
end
after = bound_default(d)
default_metadata(d)
v = unbound_default(d)
p before.arity, after.arity
p before.call, after.call
p u.call, v.call
p invoke_default(d)
