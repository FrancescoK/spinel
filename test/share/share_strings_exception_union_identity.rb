# spinel: share
# spinel: gc-minor
# An exception read through a receiver of a union of exception classes, a
# method parameter or a boxed value compares by the identity of its message,
# whichever class overrides the text and whether or not the message was
# handed on and changed in place.
class B < StandardError; end
class C < StandardError; end
class A < StandardError
  def to_s = "over"
end
class M < StandardError
  def message = "mm"
end
class T < StandardError
  def initialize(t)
    @t = t
    super("st")
  end
  def message = @t
end
n = ARGV.size
e = n == 0 ? B.new(+"x#{n}") : C.new(+"y")
p e.to_s.equal?(e.to_s), e.to_s.equal?(e.message), e.message.equal?(e.message)
p e.message.object_id == e.message.object_id
k = e.to_s
k << "!"
p e.to_s.equal?(e.to_s), e.message.equal?(k), e.message.object_id == k.object_id, e.message
def same?(x) = x.message.equal?(x.message)
p same?(B.new(+"b")), same?(C.new(+"c")), same?(A.new), same?(M.new), same?(T.new(+"t"))
def show(x) = x.message
s = show(B.new(+"q"))
s << "!"
p s
d = n == 0 ? A.new : B.new
p d.to_s.equal?(d.to_s), d.message.equal?(d.to_s)
f = n == 0 ? M.new : A.new
p f.message.equal?(f.message), f.message
t = n == 0 ? T.new(+"tm") : B.new(+"bb")
p t.message.equal?(t.message), t.message.object_id == t.message.object_id
tt = T.new(+"tt")
v = tt.message
v << "!"
p tt.message.equal?(v), tt.message.equal?(tt.message), v, tt.message
