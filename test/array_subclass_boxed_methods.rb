# An Array subclass instance read out of a mixed Array is boxed (#7449), and
# it answers as CRuby's does through the boxed path: Array's methods, reached at run time: the readers, the mutators, the
# iterators and the Enumerable ones.
# Each probe takes a fresh instance.
class Page < Array
  def initialize(src) = (super(); @src = src)
  def label = "page"
end

def fresh
  pg = Page.new("x")
  pg << 1 << 2
  objs = [pg, [9], {a: 1}, 3]
  objs[0]
end

o = fresh
p o.size
o = fresh
p o.length
o = fresh
p o.empty?
o = fresh
p o.count
o = fresh
o.push(7); p o
o = fresh
p o.push(9).equal?(o)
o = fresh
o << 7; p o
o = fresh
o.append(7); p o
o = fresh
o.unshift(0); p o
o = fresh
o.insert(1, 8); p o
o = fresh
o.concat([4]); p o
o = fresh
p o.pop
o = fresh
p o.shift
o = fresh
p o.delete(1)
o = fresh
p o.delete_at(0)
o = fresh
o.clear; p o.size
o = fresh
o.replace([8, 9]); p o
o = fresh
o.fill(0); p o
o = fresh
p o[0], o[-1], o[0, 2]
o = fresh
o[0] = 5; p o
o = fresh
p o.first, o.first(1)
o = fresh
p o.last
o = fresh
p o.take(1)
o = fresh
p o.dig(0)
o = fresh
p o.values_at(0, 1)
o = fresh
p o.include?(2)
o = fresh
p o.index(2)
o = fresh
p o.each { }.equal?(o)
o = fresh
o.each_with_index { |x, i| print x, i }; puts
o = fresh
p o.each_slice(1).to_a
o = fresh
p o.map { |x| x + 1 }
o = fresh
p o.select { |x| x > 1 }
o = fresh
p o.reject { |x| x > 1 }
o = fresh
p o.inject(:+)
o = fresh
p o.sum
o = fresh
p o.min, o.max
o = fresh
p o.sort
o = fresh
p o.sort_by { |x| -x }
o = fresh
p o.uniq
o = fresh
p o.reverse
o = fresh
p o.zip([3, 4])
o = fresh
p o.compact
o = fresh
p o.pack("C*")
