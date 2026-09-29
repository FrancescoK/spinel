# An array of arrays built by filter_map (a nested table) renders through
# p, #inspect, #to_s and interpolation, as an array of objects does.
class Pt
  def initialize(x) = @x = x
  def inspect = "Pt(#{@x})"
end
w = [1, 2].filter_map { |pa| [pa] }
p w
puts w.inspect
puts w.to_s
puts "#{w}"
f = [1, 2].filter_map { |pa| [pa * 0.5] if pa > 1 }
p f
s = %w[a b].filter_map { |x| [x, x] }
p s
o = [1, 2].map { |x| Pt.new(x) }
p o
puts o.inspect
e = [1].filter_map { |x| [x] if x > 5 }
p e
p [[1, 2], [3]].filter_map { |r| r.map { |x| x * 2 } }
