# sort_by, sort_by! and Hash#sort_by over keys whose `<=>` answers nil for a
# pair raise CRuby's ArgumentError ("comparison of String with 1 failed"),
# where they used to keep the pair in place: keys of two kinds, a nil key,
# a NaN, true against false, Arrays holding such. Keys that are equal (nil
# with nil) still compare, and keys of one kind that always compare sort as
# before.
def t
  yield
rescue ArgumentError => e
  puts "AE: #{e.message.sub(/\Acomparison of \S+ with .* failed\z/, "comparison failed")}"
end
def mk(f) = f ? [2, "x"] : 3
t { p ["a", 1].sort_by { |x| x } }
t { a = ["a", 1]; a.sort_by! { |x| x }; p a }
t { p({ a: 1, b: "x" }.sort_by { |k, v| v }) }
t { p({ "a" => 1, "b" => nil }.sort_by { |k, v| v }) }
t { p [1, 2, 3].sort_by { |x| x.odd? ? x : "s" } }
t { p [1, 2].sort_by { |x| x == 1 ? nil : 2 } }
t { p [1.0, 0.0 / 0.0].sort_by { |x| x } }
t { a = [1.5, 0.0 / 0.0]; a.sort_by! { |x| x }; p a }
t { p [[1, "a"], [1, 2]].sort_by { |x| x } }
t { p [true, false].sort_by { |x| x } }
t { p ["a", 1].sort_by(&:itself) }
t { p (1..2).sort_by { |x| x == 1 ? "a" : x } }
t { p mk(true).sort_by { |x| x } }
p [nil, nil].sort_by { |x| x }, [1, 2].sort_by { |x| :a }
p [3, 1, 2].sort_by { |x| -x }, %w[bb a].sort_by(&:size)
p [[2, "b"], [1, "a"]].sort_by { |x| x }, [2.5, 1.5].sort_by { |x| x }
p({ "a" => 1, "b" => 2 }.sort_by { |k, v| -v })
