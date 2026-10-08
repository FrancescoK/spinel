# spinel: gc-minor
# yield in method
module M
  def get = yield(@x) ? @x : @x + "y"
end
class A; include M; def initialize(x) = @x = x; end
class B; def get = "b".dup; end
src = "s".dup
os = [A.new(src), B.new]
w = [os[0].get { |s| s.size > 0 }, os[0].get { |s| false }, os[1].get { 1 }]
w[0] << "!"
w[1] << "?"
p w, src
