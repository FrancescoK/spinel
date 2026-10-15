# Array#combination, #permutation and their repeated forms without a
# block, walked with each { |x, y| } whose value is read: the block spreads
# each tuple and the walk answers the receiver
pa = [3, "a", :b]
b = [[3, 1, 2], 1][0]
a = [3, 1, 2]

p pa.permutation(2).each { |x, y| print x, y, " " }
p b.combination(2).each { |x, y| print x, y, " " }
p a.combination(2).each { |x, y| print x + y, " " }
p pa.repeated_combination(2).each { |x, y| print x, y, " " }
p b.repeated_permutation(2).each { |x, y| print x, y, " " }

p pa.combination(2).each { |x, *r| print x, r, " " }
p a.permutation(2).each { |x, y = 9| print x * y, " " }
p b.combination(2).each { |x, y, z| print x, y, z.inspect, " " }
p a.combination(2).each { |x, | print x, " " }
p pa.permutation(2).each { |*r, y| print r, y, " " }

r = pa.combination(2).each { |x, y| }
p r.equal?(pa)

p a.permutation(2) { |x, y| print x * y, " " }
p pa.combination(2) { |x, *r| print x, r, " " }

# a block inlined through a method's yield binds the tuple as written
def spread(a)
  a.combination(2).each { |x, y| yield x, y }
end
def whole(a)
  a.permutation(2) { |t| yield t }
end
spread(a) { |m, n| print m * n, " " }
spread(pa) { |m, n| print m, n, " " }
whole(a) { |t| print t, " " }
whole(b) { |t| print t, " " }
puts
