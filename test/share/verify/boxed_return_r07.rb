S = +"s"
S << "!"
class A
  def fresh = +"own"
  def pick(f) = f ? S : (fresh)
end
a = A.new
p a.pick(false)
p a.pick(true).equal?(S)
