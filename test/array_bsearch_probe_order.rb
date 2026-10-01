# Array#bsearch and #bsearch_index bisect the half-open [0, size) as CRuby
# does, so the block sees the same elements in the same order: [1, 2, 3, 4]
# probes 3 then 2. The closed [0, size - 1] probed 2 then 3, which a block
# with side effects can tell apart.
def probes
  seen = []
  r = yield(seen)
  [r, seen]
end
p(probes { |s| [1, 2, 3, 4].bsearch { |x| s << x; x >= 3 } })
p(probes { |s| [1, 2, 3, 4].bsearch_index { |x| s << x; x >= 3 } })
p(probes { |s| [1, 2, 3, 4, 5].bsearch { |x| s << x; 3 <=> x } })
p(probes { |s| [1, 2, 3, 4, 5].bsearch_index { |x| s << x; 4 <=> x } })
p(probes { |s| [1, 3, 5, 7, 9, 11].bsearch { |x| s << x; x < 4 ? nil : 7 <=> x } })
p(probes { |s| [1, 2, 3, 4].bsearch { |x| s << x; x >= 9 } })
p(probes { |s| [1, "b", :c, 4].bsearch { |x| s << x; x != 1 } })
p [].bsearch { |x| x >= 1 }, [5].bsearch { |x| x >= 1 }, [5].bsearch_index { |x| x >= 9 }
p [0, 4, 7, 10, 12].bsearch { |x| x >= 6 }, [1.5, 2.5, 3.5].bsearch { |x| x > 2.0 }
