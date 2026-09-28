# A `**` operand that answers nil carries no keywords, but it is still
# evaluated, once, where it stands: into named keywords, a **kw rest, both,
# and a later operand beside a Hash. A literal `**nil` has nothing to run.
Plain = Struct.new(:a, :b)
def k(a: 0, b: 0) = [a, b]
def m(**kw) = kw
def both(a: 0, **kw) = [a, kw]

$runs = 0
def nilf
  $runs += 1
  puts "nilf ran"
  nil
end

h = { a: 1 }
p k(**nilf)
p m(**nilf)
p both(**nilf)
p m(**h, **nilf)
p m(**nilf, **h)
p Plain.new(**nilf)
p k(**nil), m(**nil)
[1, 2].each { |i| p k(**nilf) }
p $runs
