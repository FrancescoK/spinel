class T
  def m(h) = h
  def n(a, h = nil) = [a, h]
  def z = :z
  def kw(a, k: 0) = [a, k]
end

NAMES = %i[m n z kw]
def fire(o, name, *args, **kw) = o.send(name, *args, **kw)

t = T.new
h = { k: 1 }
p fire(t, NAMES[0], **h)
p fire(t, NAMES[1], 1, **h)
p fire(t, NAMES[1], 1)
p fire(t, NAMES[1], 1, **{})
p fire(t, NAMES[2])
p fire(t, NAMES[3], 2, k: 5)
p fire(t, NAMES[3], 3)
p t.public_send(:n, 4, **h)
begin
  fire(t, NAMES[2], **h)
rescue ArgumentError => e
  puts e.message
end

class Coll
  def initialize = (@nodes = [1, "a", :b])
  def at(index) = @nodes[index]
end

class Obj
  def go = 7
end

GEM = %i[go at]
def fire2(object, name, *args, **kwargs) = object.send(name, *args, **kwargs)
p fire2(Obj.new, GEM[0])
p fire2(Coll.new, GEM[1], 1)
begin
  fire2(Coll.new, GEM[1], **{ k: 1 })
rescue TypeError => e
  puts e.message
end

def direct(h) = h
def fwd(*a, **k) = direct(*a, **k)
p direct(**h)
p fwd(**h)

c = Coll.new
[1, -1, 1.7, 0..1, 5, nil, { k: 1 }, "x", :s, [1]].each do |i|
  r = begin
    c.at(i)
  rescue TypeError => e
    "TypeError: #{e.message}"
  end
  p r
end
