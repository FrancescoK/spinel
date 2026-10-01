# A global written from an ivar that is only nil during inference (never
# assigned, assigned nil, or assigned through a multiple assignment the ivar
# pass types late) kept the scalar slot its other writes gave it. The ivar
# then took its boxed slot, and `$g = @v` assigned an sp_RbVal to an sp_int
# or sp_bool: the C did not build. ruby/spec saves and restores $VERBOSE
# that way.
$flag, @saved = false, true
p $flag
$flag = @saved
p $flag

$n = 1
$n = @never
p $n, $n.nil?

def fl = $fl
$fl = 1.5
$fl = @never
p fl

class Keeper
  def initialize = (@old = nil)
  def restore = ($s = @old)
end
$s = "s"
Keeper.new.restore
p $s

$arr = [1]
$arr = @never
p $arr
