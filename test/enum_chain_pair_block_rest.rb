# A rest (or optional/post) block parameter over an Enumerator chain whose
# source yields two values: map and its kin pass both on (a lone `*r` takes
# them spread), select and its kin pack them into one [element, index].

p [[1, 2]].each_with_index.map { |*r| r }
p [5, 6].each_with_index.map { |*r| r }
p [5, 6].each.with_index.map { |*r| r }
p [[1, 2]].each.with_index(1).map { |*r| r }
p [5, 6].map.with_index { |*r| r }
p [[1, 2]].map.with_index(1) { |*r| r }
p({a: 1}.each_with_index.map { |*r| r })
p({a: 1}.map.with_index { |*r| r })
p (1..3).each_with_index.map { |*r| r }

p [[1, 2], [3, 4]].each_with_index.map { |a, *r| [a, r] }
p [[1, 2], [3, 4]].each_with_index.map { |a, b = 9, *r| [a, b, r] }
p [[1, 2], [3, 4]].each_with_index.map { |*r, last| [r, last] }
p({a: 1}.each_with_index.map { |a, *r| [a, r] })

p [[1, 2], [3, 4]].each_with_index.flat_map { |*r| r }
p [[1, 2], [3, 4]].each_with_index.filter_map { |*r| r }
p [[1, 2], [3, 4]].each_with_index.count { |*r| r.size == 2 }
p [[1, 2], [3, 4]].each_with_index.find_index { |*r| r[1] == 1 }

p [[1, 2], [3, 4]].each_with_index.select { |*r| r.size == 1 }
p [[1, 2], [3, 4]].each_with_index.select { |a, *r| r == [1] }
p [[1, 2], [3, 4]].each_with_index.sort_by { |*r| -r[0][1] }
p [[1, 2], [3, 4]].each_with_index.group_by { |*r| r.size }
p [5, 6].select.with_index { |*r| r[1] == 1 }

p [[1, 2], [3, 4]].each_with_object([]).map { |*r| r }
p [5, 6].each_with_index.with_index.map { |*r| r }
p [5, 6].each_slice(1).map { |*r| r }
p [5, 6].each_cons(2).map { |a, *r| [a, r] }

# the same blocks forwarded through a method
def fm(a, *, &) = a.each_with_index.map(*, &)
def fb(a, &blk) = a.each_with_index.map(&blk)
def fmwi(a, &) = a.map.with_index(&)
def ffm(a, &) = a.each_with_index.flat_map(&)
def fewo(a, &) = a.each_with_object([]).map(&)
p fm([[1, 2]]) { |*r| r }
p fm([5, 6]) { |a, *r| [a, r] }
p fb({a: 1}) { |*r| r }
p fmwi([5, 6]) { |*r| r }
p ffm([5, 6]) { |*r| r }
p fewo([5, 6]) { |*r| r }

# a proc, a lambda or a Method handed over with &
pr = proc { |*r| r }
p [[1, 2]].each_with_index.map(&pr)
p [5, 6].each.with_index(1).map(&pr)
l = ->(x, i) { x + i }
p [5, 6].each_with_index.map(&l)
def m2(x, i) = x * i
p [5, 6].each_with_index.map(&method(:m2))
