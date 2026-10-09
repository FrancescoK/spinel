class A; def foo = +"a" + "b"; end
class B; def foo = 7; end
OBJS = [A.new, B.new]
class C
  def get = OBJS[0].foo
  def get3 = OBJS[0].foo
  def get4 = OBJS[0].foo
  def get5 = OBJS[0].foo
  def get6 = OBJS[0].foo
  alias get2 get
  alias_method :get7, :get6
end
def chk(r)
  arr = [r, r]
  arr[0] << "x"
  p arr
end
c = C.new
chk(c.get2)
chk(c.public_send(:get3))
chk(c.method(:get4).call)
chk([c].map(&:get5)[0])
chk(c.get7)
