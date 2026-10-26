# A receiverless call in an instance_eval block on an Array, Hash or String
# subclass instance reaches the builtin's own method.

class A < Array; end
class B < Array
  def size = 99
end
class S < String; end
class H < Hash; end
a = A.new([1, 2])
b = B.new([1])
s = S.new("ab")
h = H.new
h[:k] = 1
a.instance_eval { push(3) }
p a
p a.instance_eval { map { |x| x * 2 } }
p a.instance_eval { include?(2) }
p a.instance_eval { self.size + size }
p b.instance_eval { size }
p b.instance_eval { length }
p s.instance_eval { upcase }
p s.instance_eval { size }
h[:z] = 2
p h.instance_eval { keys }
p h.instance_eval { fetch(:z) }
p a.instance_exec(10) { |n| first + n }
r = a.instance_eval { each_with_index.map { |x, i| x + i } }
p r
x = a.instance_eval { size } + 1
p x
p a.instance_eval { [size, a.size] }
def outer(q) = q.instance_eval { last }
p outer(a)
p a.instance_eval { to_a.class }
p a.instance_eval { frozen? }
a.instance_eval { puts "in" }
p a.instance_eval { sum }
class C
  def size = 7
end
def run(o) = o.instance_eval { size }
p run(A.new([1, 2]))
p run(C.new)
size = 5
p A.new([1]).instance_eval { size }
p A.new([4]).instance_eval { first }
