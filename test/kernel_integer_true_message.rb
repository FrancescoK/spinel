# Integer() and Float() of true, false or nil name the value in their
# TypeError, as CRuby does; other kinds name their class.
p (Integer(true) rescue [$!.class, $!.message])
p (Float(true) rescue [$!.class, $!.message])
p (Integer(false) rescue [$!.class, $!.message])
p (Float(false) rescue [$!.class, $!.message])
p (Integer(:s) rescue [$!.class, $!.message])
p (Float([1]) rescue [$!.class, $!.message])
p (Integer([true, 1][0]) rescue [$!.class, $!.message])
class K
  def set = (@a = [1])
  def int = Integer(@a)
  def flt = Float(@a)
end
p (K.new.int rescue [$!.class, $!.message])
p (K.new.flt rescue [$!.class, $!.message])
