module M
  def set(x) = (@k = x)
end
class C
  include M
  def bang = @k << "!"
end
s = +"abc"
c = C.new
c.set(s)
c.bang
p s
