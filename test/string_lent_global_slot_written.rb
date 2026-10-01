# A global or a top-level / class-method ivar is lent its C slot when every
# assignment of it is in the call's own method and block: the assignment
# runs before or after the call, never during it, so the callee's append
# reaches the String the call was handed.
def gr(v) = v << "x" * 10
$g = +"g"; gr($g); p $g.size
$g = +"h"; gr($g); p $g
3.times { |i| $l = +"l#{i}"; gr($l); p $l.size }
@x = +"k"; gr(@x); @x = +"m"; gr(@x); p @x
def top = (@t = +"t"; gr(@t); @t = @t + "!"; gr(@t); @t.size)
p top
class K
  def self.run = (@k = +"k"; gr(@k); @k.size)
end
p K.run
def yl(v) = yield(v)
$y = +"y"; yl($y) { |q| q << "!" }; p $y
$y = nil
p $y
