# Hash[] takes a pair or a one-element array (a nil value) per element and
# raises ArgumentError for anything else, as CRuby does: a non-array
# element read as {nil => nil}, a longer one dropped its tail, and an odd
# number of arguments found no method. `to_h` on an Integer, Float or
# String Array raises TypeError for its first element, where it found no
# method; an empty one answers {}.
p(begin; Hash[[:a, :b]]; rescue ArgumentError, TypeError => e; [e.class, e.message]; end)
p(begin; Hash[[[:a, 1], nil]]; rescue ArgumentError, TypeError => e; [e.class, e.message]; end)
p(begin; Hash[[[:a, 1, 2]]]; rescue ArgumentError, TypeError => e; [e.class, e.message]; end)
p(begin; Hash[[[:a, 1], [:b, 2], 3]]; rescue ArgumentError, TypeError => e; [e.class, e.message]; end)
p(begin; Hash[[nil]]; rescue ArgumentError, TypeError => e; [e.class, e.message]; end)
p(begin; Hash[[[]]]; rescue ArgumentError, TypeError => e; [e.class, e.message]; end)
p(begin; Hash[[true]]; rescue ArgumentError, TypeError => e; [e.class, e.message]; end)
p(begin; Hash[[1.5]]; rescue ArgumentError, TypeError => e; [e.class, e.message]; end)
p(begin; Hash[[1, 2]]; rescue ArgumentError, TypeError => e; [e.class, e.message]; end)
p(begin; Hash[["a"]]; rescue ArgumentError, TypeError => e; [e.class, e.message]; end)
p(begin; Hash[1, 2, 3]; rescue ArgumentError, TypeError => e; [e.class, e.message]; end)
p(begin; Hash[1, 2, 3, 4, 5]; rescue ArgumentError, TypeError => e; [e.class, e.message]; end)
p(begin; [1, 2].to_h; rescue ArgumentError, TypeError => e; [e.class, e.message]; end)
p(begin; [1.5].to_h; rescue ArgumentError, TypeError => e; [e.class, e.message]; end)
p(begin; ["a"].to_h; rescue ArgumentError, TypeError => e; [e.class, e.message]; end)
p(begin; [nil, 1].to_h; rescue ArgumentError, TypeError => e; [e.class, e.message]; end)
a = [1]; a.clear
p(begin; a.to_h; rescue ArgumentError, TypeError => e; [e.class, e.message]; end)
s = ["a"]; s.shift
p(begin; Hash[s]; rescue ArgumentError, TypeError => e; [e.class, e.message]; end)
p(begin; Hash[[[:a]]]; rescue ArgumentError, TypeError => e; [e.class, e.message]; end)
p(begin; Hash[[[:a, 1], [:b]]]; rescue ArgumentError, TypeError => e; [e.class, e.message]; end)
p(begin; Hash[[["k", "v"]]]; rescue ArgumentError, TypeError => e; [e.class, e.message]; end)
p(begin; Hash[[[1, 2], [3, 4]]]; rescue ArgumentError, TypeError => e; [e.class, e.message]; end)
p(begin; Hash[{a: 1}]; rescue ArgumentError, TypeError => e; [e.class, e.message]; end)
p(begin; Hash[1, 2, 3, 4]; rescue ArgumentError, TypeError => e; [e.class, e.message]; end)
p(begin; [[1, 2]].to_h; rescue ArgumentError, TypeError => e; [e.class, e.message]; end)
