# An incomparable pair in min or max is named as CRuby names it. A literal's
# min and max (`[a, b].max`) compare each new element with the extreme so
# far, where Array#max on an array value compares the extreme with the new
# element: `[1, x].max` with x nil says "NilClass with 1", `a = [1, nil];
# a.max` "Integer with nil". A literal of static elements only (`[1, nil]`,
# `[1, "a"]` with frozen string literals) is a prebuilt Array in CRuby and
# takes Array#max's order. min(n) and max(n) cut and sort as CRuby's nmin does,
# which decides both the pair they name and the order equal elements come
# out in, and a negative size is "negative size (-1)".

def t
  yield
rescue => e
  puts "#{e.class}: #{e.message}"
end

x = 1
p x
x = nil
t { p [1, x].max }
t { p [1, x].min }
t { p [x, 1].max }
t { p [1, 2, x].max }
t { p [3, x, 1].min }
b = [1, x]
t { p b.max }
t { p b.min }
f = [1.5][ARGV.size + 1]
t { p [2.5, f].max }
t { p [f, 2.5].min }
t { p [1, "a"].max }
t { p [1, "a"].min }
a = [1, "a"]
t { p a.max }
t { p a.min }

t { p [1, x].max(1) }
t { p [1, x].min(1) }
t { p [x, 1].max(2) }
t { p b.max(1) }
t { p a.max(1) }
t { p a.min(1) }
t { p [3, 1, "a"].max(2) }
t { p [3, nil, 1, 2].max(1) }
t { p [3, 1, nil, 2].min(2) }
p [1, 1.0].max(1), [1.0, 1].max(1), [1, 1.0].min(1), [3, 1, 2].max(5)
p [5, 3, 9, 1, 7, 2, 8, 6, 4, 0].max(2), [5, 3, 9, 1, 7, 2, 8, 6, 4, 0].min(3)
t { p [1, 2].max(-1) }
t { p a.min(-2) }
