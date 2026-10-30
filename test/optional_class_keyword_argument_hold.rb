# call_args_read_in_place shape: top-level @z unset (nil) when held
def gz(v) = (@z = 0; v)
class C
  def self.ks(p1 = 0, k1: 0) = [p1, k1]
end
p C.ks(@z, k1: gz(2))
@z = 1; p C.ks(@z, k1: gz(2))
