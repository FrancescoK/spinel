# A Method turned into a Proc binds the keywords its call passes.
def mm(a, k: 1) = [a, k]
def rq(a, k:) = [a, k]
def mix(a, b = 2, *r, k: 1, j: "x") = [a, b, r, k, j]
def fl(k: 1.5) = k * 2
class Box
  def initialize; @d = 10; end
  def get(a, k: @d) = [a, k]
end

pr = method(:mm).to_proc
p pr.call(5, k: 2)
p pr.call(5)
p pr.(5, k: 3)
p pr[5, k: 4]
def yl = yield(5, k: 6)
p yl(&method(:mm))
def yl2(&b) = b.call(5, k: 7)
p yl2(&method(:mm))

pq = method(:rq).to_proc
p pq.call(1, k: 2)
begin
  pq.call(1)
rescue ArgumentError => e
  p e.message
end
begin
  pq.call(1, k: 2, z: 3)
rescue ArgumentError => e
  p e.message
end
begin
  pq.call(1, {k: 2})
rescue ArgumentError => e
  p e.message
end
h = {k: 4}
p pq.call(1, **h)

pm = method(:mix).to_proc
p pm.call(1)
p pm.call(1, 5, 6, 7, j: "y")
p pm.call(1, k: 9)
p method(:fl).to_proc.call(k: 2.5)
p method(:fl).to_proc.call
pb = Box.new.method(:get).to_proc
p pb.call(1)
p pb.call(1, k: 3)

ms = [method(:rq), method(:fl)]
p ms[0].call(1, k: 5)
p ms[1].call(k: 0.5)
p ms[0].to_proc.call(1, k: 6)
