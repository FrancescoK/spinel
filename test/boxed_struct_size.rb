# A Struct read out of a mixed Array answers size and length with its
# member count, like a plain Struct.
S = Struct.new(:a, :b)
P3 = Struct.new(:x, :y, :z)
D = Data.define(:x)
class C; end

def t
  p yield
rescue NoMethodError => e
  puts "NoMethodError"
end

s = [S.new(1, 2), 5][0]
t { s.size }
t { s.length }
t { [S.new(nil, nil), 5][0].size }
t { [P3.new(1, 2, 3), "x"][0].length }
t { [D.new(x: 1), 5][0].size }
t { [C.new, 5][0].size }
t { [[1, 2, 3], 5][0].size }
t { [+"abc", 5][0].length }
