# each_cons and the combination family answer their receiver when given a
# block, as each and each_slice do. As a method's last statement their value
# is that receiver, which the method returned as nil; a caller that wrote
# through it crashed.

def cons(a) = a.each_cons(2) { |q| q }
def comb(a) = a.combination(2) { |q| q }
def perm(a) = a.permutation(1) { |q| q }
def rcomb(a) = a.repeated_combination(1) { |q| q }
def rperm(a) = a.repeated_permutation(1) { |q| q }
a = [3, 1, 2]
p cons(a), comb(a), perm(a), rcomb(a), rperm(a)
p cons(a).equal?(a)

# an Array of mixed elements, and a Range
def mixed(a) = a.combination(1) { |q| q }
p mixed([:a, "b"])
def range_cons(r) = r.each_cons(2) { |q| q }
p range_cons(1..3)

class Rows
  def initialize = (@rows = [3, 1, 2])
  def all = @rows.repeated_combination(1) { |q| q }
  def rows = @rows

  def grow
    c = all
    c[c.size + 1] = 9
  end
end
r = Rows.new
r.grow
p r.rows
