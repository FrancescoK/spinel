S = +"s"
S << "!"
class A
  def fresh = +"own"
  def pick(f) = f ? S : (fresh)
end
y = A.new.pick(true)
y << "?"
p S, y.equal?(S)
