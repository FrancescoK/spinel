S = +"s"
def source = S
class A
  def fresh = +"own"
  def pick(f)
    source
    f ? S : (fresh)
  end
end
a = A.new
p a.pick(false).equal?(S)
p a.pick(true).equal?(S)
