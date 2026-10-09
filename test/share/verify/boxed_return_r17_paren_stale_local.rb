S = +"s"
S << "!"
class A
  def fresh = +"own"
  def pick(f) = f ? S : (fresh)
end
a = A.new
y = a.pick(true)
z = a.pick(false)
z << "?"
y << "#"
p S, z, y.equal?(S), z.equal?(S)
