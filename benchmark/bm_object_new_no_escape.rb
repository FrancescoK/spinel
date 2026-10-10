# object-new-no-escape benchmark (from yjit-bench)

class Point
  attr_reader :x, :y
  def initialize(x, y)
    @x = x
    @y = y
  end
end

def test(i)
  a = Point.new(i, 2)
  b = Point.new(i | 1, 2)
  if a.x == b.x && a.y == b.y
    1
  else
    0
  end
end

total = 0
i = 0
n = (ARGV[0] || 1000000).to_i
while i < n
  total = total + test(i)
  i = i + 1
end
puts total
puts "done"
