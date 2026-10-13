# A Struct.new or Data.define with a block that no constant or local holds
# runs its block as the class body and gives the class its defs, wherever
# the call stands: as a statement, as a value, and as a receiver.
Struct.new(:x) { puts "inline Struct body ran" }
Struct.new(:x, :y) { p self.class, self.members }
Data.define(:a) { puts "inline Data body ran" }

p Struct.new(:x) { def dbl = x * 2 }.new(3).dbl
p Struct.new(:x) { def dbl = x * 2 }.new(4)
p Data.define(:a) { def twice = a * 2 }.new(a: 5).twice

kinds = [Struct.new(:w, :h) { def area = w * h }]
p kinds.first.new(2, 3).area

def make_pair = Struct.new(:l, :r) { def sum = l + r }
p make_pair.new(1, 2).sum
