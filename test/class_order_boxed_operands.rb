# Module#<, <=, > and >= answer nil for two unrelated classes. Class values
# that reach the comparison boxed -- out of an Array, a Hash, a constant, a
# parameter, a method's value, an ivar, a block parameter, a multiple
# assignment, a mixed local, a global -- answer nil as well as true and false; and
# comparisons of boxed numbers and Strings beside them keep answering
# Booleans.
module M; end
class A; end
class B < A; include M; end
class C; end

k = [A, B, C]
p [k[0] < k[1], k[1] < k[0], k[0] < k[2], k[0] <= k[2], k[0] > k[2], k[0] >= k[2], k[1] <= M]
p [k.first > k.last, k.last < k[0], k.fetch(2) >= k.fetch(0)]

H = { a: A, c: C }
p [H[:a] < H[:c], H[:c] <= H[:a], H.fetch(:a) > B]

def cmp(x, y) = [x < y, x <= y, x > y, x >= y]
p cmp(A, C), cmp(B, A), cmp(3, 4)

def pick(i) = i.zero? ? A : (i == 1 ? C : 7)
p [pick(0) < pick(1), pick(1) > pick(0), pick(2) > 5]

class Box
  def initialize(v) = @v = v
  def lt(o) = @v < o
end
p [Box.new(A).lt(C), Box.new(B).lt(A), Box.new(2).lt(3)]

x = [true, false].first ? A : 1
p [x < C, x <= A]
u, w = C, A
v = [u, w].first
p [v < w, w < v]

p k.map { |kl| kl < A }
p k.select { |kl| (kl <= A) == nil }
acc = []
acc << C
acc.push(B)
p [acc[0] < acc[1], acc[1] < A]

$g = [A, 2].first
$h = [C, 2].first
p [$g < $h, $h <= $g]
nums = [1, "s", 2.5].first(1) + [3]
p [nums[0] < nums[1], nums[1] > 2]
ws = ["b", "a"]
p [ws[0] > ws[1]]
if k[0] < k[2]
  puts "related"
else
  puts "unrelated or not below"
end
puts((k[1] < k[0]) ? "B below A" : "no")
