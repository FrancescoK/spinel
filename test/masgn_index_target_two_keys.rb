# spinel: gc-stress
# A multiple assignment's index target with two keys (`a[i, n], x = ...`)
# stores as `a[i, n] = v` does: a scalar replaces the slice with one element,
# an Array with its elements, a length of 0 inserts, and a start past the end
# pads with nil. The receiver and both keys are read before the right side
# runs, in source order; a Hash raises the ArgumentError its two-key `[]=`
# raises, after the right side has run.
a = [1, 2, 3, 4]
a[1, 0], x = 9, :x
p a, x
a = [1, 2, 3, 4]
a[1, 1], x = 9, :x
p a, x
a = [1, 2, 3, 4]
a[1, 2], x = 9, :x
p a, x
a = [1, 2, 3, 4]
a[0, 2], x = [7, 8, 6], :x
p a, x
a = [1, 2, 3, 4]
a[1, 0], x = [7, 8], :x
p a, x
a = [1, 2, 3, 4]
a[-3, 2], x = 9, :x
p a, x
a = [1, 2, 3, 4]
a[6, 2], x = 9, :x
p a, x
a = [1, 2, 3, 4]
x, a[2, 5] = :x, [5]
p a, x
a = [1, 2, 3, 4]
a[1, 2], x = [:short]
p a, x
a = [1, 2, 3, 4]
a[1, 2], x = nil, 5
p a, x
a = [1, 2, 3, 4]
a[1, 2], a[0, 1] = [8, 8], 0
p a
f = [1.5, 2.5, 3.5]
f[1, 2], x = 9.5, :x
p f
s = ["a", "b", "c"]
s[0, 2], x = ["x", "y", "z"], :x
p s
s[1, 1], x = "q", :x
p s
m = [1, "two", :three, 4.0]
m[1, 2], x = [nil, 5], :x
p m
(a[0, 2], b), c = [[5, 6], 7], 8
p a, b, c

# the keys and the receiver are read before the right side runs
i = 0
n = 1
bump = -> { i += 1; n += 1; 5 }
a = [0, 0, 0, 0, 0]
a[i, n], x = bump.call, 2
p a, i, n, x
b = [1, 2, 3, 4, 5]
k = 0
b[(k += 1), (k += 1)], x = [k, 9], 2
p b, k, x
$log = []
def at(v) = ($log << v; v)
c = [1, 2, 3, 4, 5]
c[at(0), at(2)], x = at(7), at(8)
p c, x, $log

# a boxed receiver goes through the same splice
def pk(j) = [[1, 2, 3, 4], ["a", "b", "c"]][j]
r = pk(0)
r[1, 2], x = 9, :x
p r
r = pk(1)
r[0, 1], x = ["z", "w"], :x
p r

# a Hash raises after the right side has run
h = {1 => 2}
ran = false
begin
  h[1, 2], x = (ran = true; 3), 4
rescue ArgumentError => e
  puts e.message, ran
end
p h

# a boxed receiver that is no Array
def odd(j) = [[1, 2, 3, 4], {1 => 2}, nil, :sym, 5][j]
5.times do |j|
  o = odd(j)
  begin
    o[0, 2], x = 9, 1
    p o
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
end
