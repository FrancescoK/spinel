# Range#bsearch on a range built from boxed bounds: the range the box holds
# is an Integer or a Float range only at run time, and each answers as
# CRuby's does -- the least member the block accepts, or nil. The Float
# range bisects its run-time bounds, also in the shape
# `(from...size).bsearch { ... } || size`.
# (promote-skip.txt: under promote a Range of boxed ends keeps the Integer
# representation, which a Float begin is refused in.)

class Bag
  def size = 4.0
end

class Act
  def initialize(ch) = @children = ch

  def bsearch_child_index(from = 0)
    size = @children.size
    (from...size).bsearch { |i| yield @children[i] } || size
  end
end

a = Act.new([[1, 3, 5, 7], Bag.new][ARGV.size])
p a.bsearch_child_index { |c| c > 2 }
p a.bsearch_child_index([2, 1.5, nil][ARGV.size]) { |c| c > 6 }
p a.bsearch_child_index { |c| c > 100 }

lo = [0.5, 0, nil][ARGV.size]
hi = [9.5, 10, nil][ARGV.size]
p (lo...hi).bsearch { |f| f >= 2.5 }
p (lo..hi).bsearch { |f| f >= 100 }
lo2 = [0, 0.5, nil][ARGV.size]
hi2 = [10, 9.5, nil][ARGV.size]
p (lo2...hi2).bsearch { |i| i >= 4 }
