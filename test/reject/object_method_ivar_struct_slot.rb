# A Struct's member and an ivar of the same name need separate storage.
class Object
  def store(v) = (@x = v)
end
S = Struct.new(:x)
s = S.new(1)
p s.store(2), s.x, s.instance_variable_get(:@x)
