# A Float begin before an end only known at run time: `(1.5..x)`. It was an
# Integer range, the begin truncated, and a nil end read as 0 (`1..0`). It
# is a Float range now, and an end that is nil at run time leaves it endless
# as CRuby's: it inspects as "1.5..", answers nil from #end, raises the
# RangeError from #last / #max and the TypeError from Float when enumerated.

def t(s)
  r = yield
  puts "#{s}: #{r.inspect}"
rescue StandardError => e
  puts "#{s}: #{e.class}: #{e.message}"
end

src = [1.5, nil, 2.5, 3, 4.5]
f = (1.5..src[1])
g = (1.5..src[3])
k = (1.5...src[4])
t("f") { f }
t("g") { g }
t("k") { k }
t("f include") { f.include?(100.0) }
t("g include") { g.include?(100.0) }
t("k include") { k.include?(4.5) }
t("f ===") { f === 1.0 }
t("f cover") { f.cover?(2.0) }
t("f begin") { f.begin }
t("f end") { f.end }
t("k end") { k.end }
t("f first") { f.first }
t("f min") { f.min }
t("f last") { f.last }
t("f max") { f.max }
t("k max") { k.max }
t("f each") { f.each { |i| } }
t("f to_a") { f.to_a }
t("f map") { f.map { |v| v } }
t("f max2") { f.max(2) }
t("f min2") { f.min(2) }
t("f ==") { f == (1.5..src[1]) }
t("f exclude_end") { f.exclude_end? }
