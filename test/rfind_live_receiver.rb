ary = [4, 2, 1, 5, 1, 3]
seen = []
p(ary.rfind { |x| seen << x; ary.clear; false })
p seen

ary = [4, 2, 1, 5, 1, 3]
seen = []
p(ary.rfind { |x| seen << x; ary.pop(2) if x == 3; false })
p seen

ary = [4, 2, 1, 5, 1, 3]
seen = []
p(ary.rfind { |x| seen << x; ary.pop(2) if x == 3; x == 2 })
p seen

strs = %w[a b c d]
seen = []
p(strs.rfind(-> { :none }) { |s| seen << s; strs.shift(3) if s == "d"; false })
p seen

mixed = [1, "two", :three, 4.0]
seen = []
p(mixed.rfind { |x| seen << x; mixed.clear; false })
p seen

visited = []
p [1, 2, 3, 4, 5].rfind { |x| visited << x; x == 3 }
p visited
p [1, 2, 3].rfind { |x| next false if x == 3; x.even? }
