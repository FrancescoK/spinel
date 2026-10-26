# An Array subclass instance is an Array already: Array's operators,
# concat and a splice write take its own elements and never call the
# class's own #to_ary (CRuby's rb_check_array_type).
class T < Array
  def to_ary = [55]
end

t = T.new([1, 2])
p [9].concat(t)
p [9] + t
p [9, 1] - t
p [9] | t
p [1, 9] & t
p([1, 2] <=> t)
x = [9]
x.concat(t)
p x
y = [7, 8]
y[0, 1] = t
p y
z = [7, 8]
z[0..0] = t
p z
w = [7, 8]
p(w[1, 1] = t)
p w

def plus(a) = [9] + a
p plus(t)
2.times { p [3].concat(t) }

# a class that is not an Array still converts through its #to_ary
class W
  def to_ary = [4, 5]
end
p [9] + W.new
v = [7, 8]
v[0, 1] = W.new
p v

# a splice of a subclass whose to_ary has other kinds keeps the Integer slot
class S < Array
  def to_ary = [1, "x"]
end
u = [7, 8]
u[0, 1] = S.new([3, 4])
p u.sum
