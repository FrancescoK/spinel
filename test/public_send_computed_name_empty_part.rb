# A computed send name whose interpolation is empty is its literal parts
# alone: `"[]#{op}"` with op "" is `[]`, and `"foo#{x}"` with x "" is `foo`.
# Narrowing the candidates to the literal parts' shape keeps such a name.
class Box
  def initialize = @h = {}
  def [](k) = @h[k]
  def []=(k, v)
    @h[k] = v
  end
  def foo = "foo"
  def foobar = "foobar"
end
class Other
  def baz = 1
end
def index_op(o, op, *args) = o.public_send("[]#{op}", *args)
def foo_op(o, sfx) = o.send("foo#{sfx}")
objs = [Box.new, Other.new]
b = objs[0]
index_op(b, "=", :k, 42)
p index_op(b, "", :k)
p foo_op(b, ""), foo_op(b, "bar")
begin
  foo_op(objs[1], "")
rescue NoMethodError => e
  puts "NoMethodError #{e.name}"
end
