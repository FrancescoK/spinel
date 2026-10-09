S = +"s"
S << "!"
class A
  def fresh = +"own"
  def pick(f) = f ? S : (fresh)
end
p A.new.pick(true).equal?(S)
