# A lambda written as one value of a join (`f && lambda { }`, `f ? lambda { }
# : nil`, `(f; lambda { })`) and called through the local that holds it
# (`pr.call`, `pr.(x)`, `map(&pr)`). The literal's parameters took the Integer
# default of a literal nothing escapes, because the writes the search for the
# literal looked at were those whose value is the literal itself: the String
# element was read through an Integer slot and `s + "!"` raised "String can't
# be coerced into Integer". A literal that shares its slot with other values
# escapes (its parameters are boxed) wherever the join goes: a variable, an
# argument, a method's value, a block's value, a global; and a sequence's last
# value is typed from the call as the literal itself is.
f = ARGV.empty?
pr = f && lambda { |s| s + "!" }
p ["a"].map(&pr)
p pr.call("b")

pr2 = f ? lambda { |s| s + "?" } : nil
p ["a"].map(&pr2)
p pr2.call("b")

pr3 = (f; lambda { |s| s + "#" })
p ["a"].map(&pr3)
p pr3.call("b")

pr4 = nil || lambda { |s| s + "." }
p ["a"].map(&pr4)
p pr4.call("b")

pr5 = (f ? 1 : 2; proc { |s| s + "," })
p ["a"].map(&pr5)
p pr5.call("b")

pr6 = f && lambda { |a| a.map { |e| e * 2 } }
p pr6.call([1, 2])
p pr6.(["x"])

$g = ARGV.empty? && ->(s) { s + "?" }
p $g.call("g")

def run(pr) = pr.call("a")
p run(ARGV.empty? && ->(s) { s + "?" })

def make(f) = f ? lambda { |s| s.size } : nil
p make(true).call("abc")
p %w[a bb].map(&make(true))

p [1].map { ARGV.empty? && ->(s) { s + "?" } }.first.call("q")
