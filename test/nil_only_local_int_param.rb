# A local that only ever holds nil, handed to an Integer or Float
# parameter another call types, is nil inside the method: the parameter
# holds nil beside the numbers, whether the method reads it or not. A
# parameter whose first use is an operator raises that operator's error at
# the call, as CRuby does inside the method.

def unread(k, v) = :y
unread(0, 1)
x = nil
p unread(1, x)

def show(v) = v.inspect
show(1)
p show(x)
y = x
p show(y)
[1].each { p show(x) }
f = ->(q) { show(q) }
p f.(x)

def flt(v) = v
p flt(1.5)
p flt(x)
p [flt(x), flt(2.5)]

def opt(a, b = 2) = [a, b]
p opt(1)
p opt(1, x)

def kw(v: 0) = v.inspect
kw(v: 1)
p kw(v: x)

class Box
  def initialize = (@h = {})
  def []=(k, v)
    @h[k] = v
  end
  def [](k) = @h[k]
end
b = Box.new
b[0] = 1
b[1] = x
p b[0], b[1]

def dbl(v) = v * 2
p dbl(3)
begin
  p dbl(x)
rescue NoMethodError => e
  p e.message
end

def addf(v) = v + 1.5
p addf(3.0)
begin
  p addf(x)
rescue NoMethodError => e
  p e.message
end

def addi(v) = 2 + v
p addi(3)
begin
  p addi(x)
rescue TypeError => e
  p e.message
end
