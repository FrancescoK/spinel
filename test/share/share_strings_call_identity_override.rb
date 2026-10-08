# Identity demand must not hide a user-defined String method's dispatch.
S = +"s"
def get = S
S << "!"

class String
  def equal?(other) = 73
  def object_id = 81
  def __id__ = 83
  def frozen? = 92
end

p get.equal?(S)
p S.equal?(get)
p get.equal?(get)
p get.object_id
p get.__id__
p get.frozen?
