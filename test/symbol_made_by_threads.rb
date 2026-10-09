# Threads that make new Symbols at the same time: each name is one Symbol,
# and each Symbol keeps its name.
#
# Two Threads that missed in the pool both stored into the slot at its end
# and both counted it. The slot after it stayed empty, and the next lookup
# read through it; where both had made the same name it became two Symbols,
# and where the names differed one Symbol answered to the other's name.
same = (0...4).map do
  Thread.new do
    (0...3_000).map { |i| ("n" + i.to_s).to_sym }
  end
end.map(&:value)
p same.all? { |syms| syms == same[0] }
p same[0].uniq.length
p same[0].each_with_index.all? { |s, i| s.to_s == "n" + i.to_s }
p same[0][0], same[3][2999]

# each Thread its own names
own = (0...4).map do |t|
  Thread.new do
    n = 0
    2_000.times { |i| n += 1 if ("t" + t.to_s + "_" + i.to_s).to_sym.to_s == "t" + t.to_s + "_" + i.to_s }
    n
  end
end
p own.map(&:value)
