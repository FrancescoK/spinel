S = +"s"
S << "!"
def source = S
class A
  def fresh = +"own"
  def pick(f)
    source
    f ? S : (fresh)
  end
end
a = A.new
z = a.pick(false)
z << "?"
p S, z
