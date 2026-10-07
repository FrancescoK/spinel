class Guard
  def go = 7
  def add(a) = a + 1
  def pair(a, b) = [a, b]
  def kw(a, scale: 2) = a * scale
end

def evaluate_method(object, method, *args, **, &block)
  object.send(method, *args, **, &block)
end

def evaluate_named(object, method, *args, **kw)
  object.send(method, *args, **kw)
end

NAMES = %i[go add pair kw end begin offset]
m = "spinel".match(/in/)
p [m.begin(0), m.end(0), m.offset(0)]

g = Guard.new
p evaluate_method(g, NAMES[0])
p evaluate_method(g, NAMES[1], 41)
p evaluate_method(g, NAMES[2], :a, :b)
p evaluate_method(g, NAMES[3], 5)
p evaluate_method(g, NAMES[3], 5, scale: 3)
p evaluate_named(g, NAMES[1], 1)
p evaluate_named(g, NAMES[3], 4, scale: 10)
p evaluate_method(g, :go) { :unused }

def pick(x, o)
  r = x == 0 ? 5 : (x == 1 ? o.zork : raise(ArgumentError, "bad #{x}"))
  r + 1
end
p pick(0, g)
[1, 2].each do |i|
  pick(i, g)
rescue NoMethodError, ArgumentError => e
  puts e.class
end
