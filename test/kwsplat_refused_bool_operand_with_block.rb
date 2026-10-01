# A call with a literal key and a `**` operand into a `**nil` method that
# yields: the operand is run and judged once. true, false, a Boolean local
# and a nilable Integer raise CRuby's TypeError before the method's
# "no keywords accepted"; nil and an empty Hash bring no keywords.
def m(p1, *r, **nil) = block_given? ? yield([p1, r]) : p1
def eff(v) = (puts "ran"; v)

b = rand < 2
n = (1 if rand < 2)
p((m(1, *[4], "s" => 6, **true) { |x| x } rescue $!.class))
p((m(1, "s" => 6, **true) { |x| x } rescue $!.message))
p((m(1, "s" => 6, **false) { |x| x } rescue $!.message))
p((m(1, "s" => 6, **b) { |x| x } rescue $!.message))
p((m(1, *[4], "s" => 6, **n) { |x| x } rescue $!.message))
p((m(1, "s" => 6, **nil) { |x| x } rescue $!.message))
p((m(1, "s" => 6, **{}) { |x| x } rescue $!.message))
p((m(1, "s" => 6, **eff(true)) { |x| x } rescue $!.message))
p((m(1, "s" => 6, **true) rescue $!.message))
p m(1, *[4]) { |x| x }
