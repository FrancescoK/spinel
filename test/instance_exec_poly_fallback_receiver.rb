# A boxed receiver of none of the ivar-owning classes runs an ivar-reading
# instance_exec block once, on the receiver it evaluated, with self that
# receiver; a nested instance_eval there still reads its own receiver's ivars.

class Foo; def initialize; @v = 9; end; end
$i = 0
def nxt
  $i += 1
  [Foo.new, 5, "s"][$i % 3]
end
3.times { p nxt.instance_exec(1) { |a| [@v, a] } }
p $i
3.times { p nxt.instance_eval { @v } }
p $i

[Foo.new, 5].each { |x| p x.instance_exec(1) { |a| [@v, a, self.class] } }

other = Foo.new
[1, Foo.new].each { |x| p x.instance_exec { [@v, other.instance_eval { @v }] } }
