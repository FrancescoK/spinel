# Array#each_index given a Proc, a lambda or a method's own block through
# `&`: the block runs once per index, as a written one does

class C
  def initialize(a) = (@a = a)
  def each_index(&blk) = @a.each_index(&blk)
end
C.new([9, 8]).each_index { |i| print i, " " }
puts
pr = proc { |i| print i * 10, " " }
[1, 2, 3].each_index(&pr)
puts
p [4, 5].each_index(&pr)
p(%w[a b].each_index(&->(i) { print i }))
