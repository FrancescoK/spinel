# A sort, sort!, min or max block that answers nil says the two elements do
# not compare: CRuby raises ArgumentError ("comparison of A with b failed").
# An Integer answer that can be nil (`<=>` of boxed or Float operands, a
# branch answering nil) sorted as if it said "less", and a block that is
# always nil (`{ nil }`, an empty block) was ignored on a typed Array and
# raised NoMethodError on a general one.
def t
  yield
rescue ArgumentError => e
  puts "AE: #{e.message}"
end
# The pair a sort compares first depends on its algorithm (CRuby's own
# qsort or the C library's), so a sort's message is shown with its
# operands cut; min and max walk in order and name theirs.
def ts
  yield
rescue ArgumentError => e
  m = e.message
  cut = m.start_with?("comparison of ") && m.end_with?(" failed")
  puts "AE: #{cut ? "comparison of _ with _ failed" : m}"
end
def cmpf(a, b) = a > 100 ? a <=> b : nil

ts { p [1, "x"].sort { |a, b| b <=> a } }
ts { a = [1, "x"]; a.sort! { |x, y| y <=> x }; p a }
t { p [1, "x"].min { |a, b| a <=> b } }
t { p [1, "x"].max { |a, b| a <=> b } }
ts { p({ 1 => 2, "a" => 3 }.sort { |a, b| a[0] <=> b[0] }) }
ts { p [3, 1, 2].sort { |a, b| a > 5 ? a <=> b : nil } }
t { p [3, 1, 2].min { |a, b| a > 5 ? a <=> b : nil } }
t { p [3, 1, 2].max { |a, b| cmpf(a, b) } }
ts { p [3, 1, 2].sort { |a, b| next nil if a < 5; a <=> b } }
ts { p [2.0, 0.0 / 0.0].sort { |a, b| a <=> b } }
t { p [2.0, 0.0 / 0.0].max { |a, b| a <=> b } }
ts { p %w[b a].sort { |a, b| a > "z" ? a <=> b : nil } }

ts { p [3, 1, 2].sort { |a, b| nil } }
ts { p [3, "a", 2].sort { |a, b| nil } }
ts { a = [3, 1, 2]; a.sort! { |x, y| nil }; p a }
ts { p [3, 1, 2].sort { } }
t { p [3, 1, 2].min { } }
t { p [3, "a", 2].max { |a, b| nil } }
ts { p %w[b a].sort { nil } }
t { p [:b, :a].max { |a, b| nil } }
ts { p({ "b" => 1, "a" => 2 }.sort { |x, y| nil }) }
t { p({ "b" => 1, "a" => 2 }.min { |x, y| nil }) }
t { p((1..3).max { |a, b| nil }) }

p [3, 1, 2].sort { |a, b| b <=> a }, [3, 1, 2].min { |a, b| b <=> a }
p [1].sort { nil }, [1].min { nil }, [].max { nil }
p ["b", 1].sort { |a, b| a.to_s <=> b.to_s }
