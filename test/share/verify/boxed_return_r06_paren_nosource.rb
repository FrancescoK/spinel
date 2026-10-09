S = +"s"
class A
  def fresh = +"own"
  def pick(f) = f ? S : (fresh)
end
a = A.new
p a.pick(false).equal?(S)
p a.pick(true).equal?(S)
