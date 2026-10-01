# A Data class reached as a Class value (`[P0][0].new(1)`) and given a count
# of positionals its members do not take raises CRuby's ArgumentError, also
# for a Data class with no members. The constructor switch had no arm for
# it, and its default raised NoMethodError.

P0 = Data.define
P2 = Data.define(:a, :b)
p(([P0][0].new(1) rescue [$!.class, $!.message]))
p(([P2][0].new(1) rescue [$!.class, $!.message]))
p(([P2][0].new(1, 2, 3) rescue [$!.class, $!.message]))
p [P2][0].new(1, 2), [P0][0].new
