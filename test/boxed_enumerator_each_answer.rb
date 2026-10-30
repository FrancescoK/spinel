# A boxed Enumerator's each answers what its walk answers, walking it once
# The walk over a boxed generator ran its body, and the call's answer was
# read back through the Enumerator's to_a, which ran the body again and
# answered the items: a generator's `each { }` answers its body's value.
# A materialized one answers its source, as before.

def box(x) = [x, 1].first
p(box([1, 2, 3].each).each { |x| x })
p(box((1..3).each).each { |x| x })
runs = 0
gen = Enumerator.new { |y| runs += 1; y << 1; y << 2; :body_done }
p box(gen).each { |x| x }, runs
def walk(v) = v.each { |x| x }
runs = 0
p walk(box(gen)), runs
runs = 0
seen = []
box(gen).each { |x| seen << x }
p seen, runs
runs = 0
p(box(gen).each { |x| break x * 10 if x == 2 }, runs)
endless = box(Enumerator.new { |y| n = 0; loop { y << (n += 1) } })
got = []
endless.each { |x| got << x; break if x == 3 }
p got
r = box([4, 5].each).each { |x| x }
p r
p(box([7, 8]).each { |x| x })
