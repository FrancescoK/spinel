# Boxed Symbols, nil, true and false compare by kind and value (#10550),
# and boxed Strings by bytes and encoding.
vals = [:a, :b, nil, true, false, 1, 1.0, "a", "a".b, "\xff".b, "é", :a, nil, true]
vals.each_with_index do |x, i|
  row = vals.each_with_index.map { |y, j| x == y ? 1 : 0 }
  puts "#{i}: #{row.join}"
end
p vals.count(nil), vals.count(:a), vals.count(true), vals.count(false)
p vals.index(false), vals.include?(:b), vals.uniq.size
p ["a", "a".b].map { |s| s == "a" }, ["\xff".b, "é".b].map { |s| s == "\xff".b }
