# A callable held in a poly slot takes keywords while a user class also
# defines #call.
class Cal; def call(a, h = nil) = [:cal, a, h]; end
def mm(a, k: 1) = [a, k]
def hh(a, h) = [a, h]
pr = proc { |a, k: 1| [a, k] }
la = ->(a, k: 1) { [a, k] }
boxed = [pr, Cal.new, la, method(:mm), method(:hh), proc { |a, **o| [a, o] }]
p boxed[0].call(5, k: 2)
p boxed[0].call(5)
p boxed[0].(5, k: 3)
p boxed[0].call(5, {k: 2})
p boxed[1].call(5, k: 2)
p boxed[2].call(5, k: 2)
p boxed[2][5, k: 7]
p boxed[3].call(5, k: 3)
p boxed[3].(5, k: 8)
p boxed[4].call(5, k: 3)
p boxed[5].call(5, k: 3, j: 4)
begin
  boxed[2].call(5, z: 2)
rescue ArgumentError => e
  p e.message
end
