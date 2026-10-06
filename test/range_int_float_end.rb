# An Integer Range whose end is a Float, (1..2.5), walks from the Integer
# as CRuby does and keeps the end as written. The end was truncated when the
# Range was built: (1...2.5) walked only 1, a Range held in an element, a
# box or a Hash answered 2 for #end / #max / #minmax / #to_s, and
# include?(2.2) / cover?(2.4) / === 2.4 were false.

def t(s)
  r = yield
  puts "#{s}: #{r.inspect}"
rescue StandardError => e
  puts "#{s}: #{e.class}: #{e.message}"
end

puts "-- literal and local"
t("literal minmax") { (1..2.5).minmax }
t("local max") { q = (1..2.5); [q.max, q.end, q.last] }
t("local minmax") { q = (1..2.5); q.minmax }
t("membership") { q = (1..2.5); [q.include?(2.2), q.cover?(2.4), q === 2.4, q.include?(2), q.include?(3)] }
t("to_s") { q = (1..2.5); [q.to_s, q.inspect, (1...2.5).to_s] }
t("walk") { q = (1..2.5); [q.to_a, (1...2.5).to_a, (1...3.0).to_a, (-5..-2.5).to_a] }
t("size") { q = (1..2.5); [(1..2.5).size, (1...2.5).size, (1...3.0).size, q.count, q.sum] }
t("excl") { [(1...2.5).exclude_end?, (1...2.5).end] }
t("excl max") { (1...2.5).max }
t("empty") { [(3..2.5).max, (3..2.5).min, (2...2.0).min, (3..2.5).minmax] }
t("eq") { q = (1..2.5); [q == (1..2.5), q == (1..2), (1..2.0) == (1..2), (1..2.0).eql?(1..2)] }
t("cover range") { [(1..2).cover?(1..2.5), (1..2.5).cover?(1..2), (1...2.5).cover?(1..2.5), (1...2.5).cover?(1...2.5)] }
t("for") { a = []; for i in 1...2.5 do a << i end; a }
t("first last n") { q = (1..2.5); [q.first(5), q.last(5)] }

puts "-- held elsewhere"
r = (1..2.5)
a = [r, (1..3)]
t("element") { [a[0].max, a[0].end, a[0].minmax, a[0].to_s, a[0].include?(2.2)] }
h = { k: r }
t("hash value") { [h[:k].end, h[:k].max] }
mix = [r, "x", (1...2.5)]
t("boxed") { [mix[0].max, mix[0].end, mix[0].last, mix[0].inspect, mix[0].include?(2.2), mix[0].minmax] }
t("boxed excl") { [mix[2].exclude_end?, mix[2].to_a, mix[2].end] }
t("boxed excl max") { mix[2].max }

puts "-- a boxed end"
e = [2.5, 3, nil][0]
t("for") { b = []; for i in 1..e do b << i end; b }
t("for excl") { b = []; for i in 1...e do b << i end; b }
t("each excl") { b = []; (1...e).each { |i| b << i }; b }
t("readers") { x = (1..e); [x.to_s, [x].map(&:end), x.to_a] }
t("Range.new") { Range.new(1, e).to_a }
f = [1.5, 2][0]
t("float begin for") { b = []; for i in f..4 do b << i end; b }

puts "-- bisection and steps"
t("bsearch") { [(1..2.5).bsearch { |x| x >= 2 }, (1..2.5).bsearch { |x| x >= 1.5 }] }
t("step 1") { s = []; (1..2.5).step(1) { |x| s << x }; s }
t("step 0.5") { s = []; (1..2.5).step(0.5) { |x| s << x }; s }
def half(rg) = rg.step(0.5).to_a
t("step 0.5 through a parameter") { half(1..2.5) }
t("hash") { [(1..2.5).hash == (1..2.5).hash, (1..2.5).hash == (1..2).hash] }
