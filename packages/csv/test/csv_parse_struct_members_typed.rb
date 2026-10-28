# A program that parses with the bundled csv keeps its Structs' Float
# members typed: csv's Row#[]= is reached by no call (Row#to_h's `h[k] = v`
# is on a Hash literal), so its `@fields[key] = value` types no Struct's
# members (#10489).
require "csv"

Point = Struct.new(:x, :y) do
  def dist2(o) = (x - o.x) ** 2 + (y - o.y) ** 2
end

text = (0...20).map { |i| "#{i * 0.5},#{i * 0.25}" }.join("\n")
pts = CSV.parse(text).map { |r| Point.new(r[0].to_f, r[1].to_f) }
s = 0.0
pts.each { |a| pts.each { |b| s += a.dist2(b) } }
p s
p pts[3].x
p CSV.parse("a,b\n1,2").map(&:size)
