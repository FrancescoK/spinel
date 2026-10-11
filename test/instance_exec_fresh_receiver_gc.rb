# spinel: gc-stress
# A fresh receiver that instance_exec's block reads after it allocates
# stays alive while the block runs: nothing else holds it.
class K
  def initialize(n) = @name = n
  def name = @name
end
class M
  def initialize(n) = @name = n
end
3.times do |i|
  r = K.new("n#{i}").instance_exec { a = [1, 2, 3].map { |x| "v#{x}" }; [a.size, @name] }
  p r
end
u1 = +"uu"
u2 = +"vv"
n2 = K.new(u1).instance_exec { x = M.new(u2).instance_exec { @name }; [x, @name] }
p n2
n3 = K.new("k").instance_eval { b = (1..4).map { |x| x.to_s * 3 }; [b.last, name] }
p n3
# a receiver with no instance variable layout: an Array, a Hash, a String,
# and a Range, which its box holds as a new object
p [3, 1, 2].instance_exec { t = map { |x| "e#{x}" }; [t, sort, size] }
p({ a: 1, b: 2 }.instance_exec { k = keys.map(&:to_s); [k, size] })
p "ab#{u1}".instance_exec { w = chars.map { |c| c * 2 }; [w.join, length] }
h = { k: 3 }
p((1..4).instance_exec(**h) { |k: 1| [k, sum] })
r = (2..5)
p(r.instance_exec(**h) { |k: 1| [k, sum, to_a.map { |x| x.to_s * 2 }] })
