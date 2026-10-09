S = +"s"
class A
  def fresh = +"own"
  def pick(f) = f ? S : (fresh)
end
a = A.new
p a.pick(true)
p a.pick(true).equal?(S)
