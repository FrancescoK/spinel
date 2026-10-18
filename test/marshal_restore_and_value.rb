# Marshal.restore is Marshal.load by another name, and the Marshal module is
# a value like any other: it prints, names itself, and a variable holding it
# dumps and loads. Both raised NameError (uninitialized constant Marshal).
# Another module in the variable has no such method.

class Point
  attr_accessor :x, :y
  def initialize(x, y) = (@x = x; @y = y)
end

blob = Marshal.dump([1, "a", { b: 2 }])
p Marshal.restore(blob)

m = [Marshal, Math][0]
p m, Marshal.name, Marshal.class
s = m.dump([1, 2])
p s.bytesize, m.load(s), m.restore(s)
pt = m.load(m.dump(Point.new(3, "four")))
p pt.class, pt.x, pt.y

begin
  [Marshal, Math][1].dump(1)
rescue NoMethodError => e
  puts e.message
end
