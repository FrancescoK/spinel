# The finalizers of what an allocation-triggered collection freed run while
# the program is still going: at a loop's back-edge or a method's entry, not
# inside the allocation that collected, and not only at exit.
$fin = 0
class Res
  def initialize(n)
    @n = n
    @pad = "p" * 64
    ObjectSpace.define_finalizer(self, Res.fin)
  end
  def self.fin = proc { |_id| $fin += 1 }
end

i = 0
while i < 100_000
  Res.new(i)
  i += 1
end
p $fin > 0

def make(n) = Res.new(n)
seen = $fin
100_000.times { |n| make(n) }
p $fin > seen
