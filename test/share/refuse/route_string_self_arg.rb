# A String method receives bytes; forwarding self would lose the mutation.
def grow(s)
  s << "!"
  nil
end
class String
  def pass_self = grow(self)
end
s = +"a"
s.pass_self
p s
