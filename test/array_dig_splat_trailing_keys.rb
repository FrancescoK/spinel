# a splat followed by another dig key: boxed receiver and poly-array receiver
def churn; (1..60).map { |i| [i, "s#{i}"] }; nil; end
def pvn(n) = n > 0 ? (1..40).map { |i| [i, i.odd? ? i * 10 : "s#{i}"] } : "str"
def pan = (1..40).map { |i| [i, i.odd? ? i * 10 : "s#{i}"] }
begin
  p pvn(1).dig(*(churn; [5]), 1)
rescue => e
  puts "boxed: #{e.class}"
end
pa = pan
p pa.dig(*(churn; [5]), 1)

# Multiple splats retain the following keys, and all arguments evaluate once.
def path
  puts "path"
  GC.start
  [0]
end
def suffix
  puts "suffix"
  GC.start
  [0]
end
nested = [[["value", 9]], 0]
p nested.dig(*path, *suffix, 0)
p nested.dig(*[], 0, *[0], 1)
p nested.dig(*[5], 0)
# A typed Hash takes the keys after the splat the same way.
h = {a: {b: 1}}
k = [:a]
p h.dig(*k, :b)

# the keys after the splat run, in order, and a scalar on the way raises
def key(v) = (print v, " "; v)
pa = [[1, "x"], [2, "y"]]
z = [0]
pb = [[[1, 2], [3, 4]]]
p pb.dig(*z, key(1), key(0))
p((pa.dig(*z, 0, 0) rescue [$!.class, $!.message]))
ka = [:a]
p(({a: {b: 5}}.dig(*ka, :b, :c) rescue [$!.class, $!.message]))
