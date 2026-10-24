# spinel: reject-subclass: a method defined in an instance_eval block
# instance_exec evaluates its argument and hands it to the block. The defs
# of a block of defs only are registered at compile time, so the argument
# would never be evaluated; the call is refused rather than dropping it.
class Shape; end
$log = []
def note(x) = ($log << x; x)
Shape.instance_exec(note(:arg)) { |_a| def sides = 4 }
p Shape.sides, $log
