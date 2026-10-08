# partition and group_by are defined in Ruby (builtins/enumerable.rb): every
# receiver kind, the blockless Enumerator form, a class that includes
# Enumerable, a run-time receiver, the String#partition that shares the name
# (a different arity, left to String), and the block forwarded three ways.
# spinel: share
a, b = [1, 2, 3, 4].partition { |x| x.odd? }
p a, b
p ["a", "bb", "c"].partition { |s| s.size == 1 }
p({ a: 1, b: 2 }.partition { |k, v| v > 1 })
p (1..6).partition { |x| x > 3 }
p [1, 2, 3].each_with_index.partition { |x, i| i > 0 }

g = [1, 2, 3, 4].group_by { |x| x % 2 }
p g
p g[0]
p ["ab", "cd", "e"].group_by { |s| s.size }
p({ a: 1, b: 2, c: 1 }.group_by { |k, v| v })
p [1, 2, 3].group_by { |x| x > 1 ? :big : :small }
p (1..5).group_by { |x| x % 3 }

p [1, 2].partition.class
p [3, 4].group_by.to_a
p([1, 2, 3].partition.each { |x| x > 1 })

class Bag
  include Enumerable
  def initialize(*xs) = @xs = xs
  def each(&) = @xs.each(&)
end
p Bag.new(3, 4, 5).partition { |x| x > 3 }
p Bag.new(3, 4, 5).group_by { |x| x > 3 }

def pick(i) = [[1, 2, 3], { k: 1 }, "a;b"][i]
p pick(0).partition { |x| x > 1 }
p pick(0).group_by { |x| x > 1 }
p pick(2).partition(";")
p "x;y".partition(";")

def fwd_part(&b) = [1, 2, 3].partition(&b)
def fwd_grp(&b) = ["a", "bb"].group_by(&b)
odd = ->(x) { x.odd? }
p fwd_part(&odd)
p(fwd_part { |x| x > 1 })
len = ->(s) { s.length }
p fwd_grp(&len)
p(fwd_grp { |s| s.upcase })
p [1, 2, 3].partition(&:even?)
p ["a", "bb"].group_by(&:size)

v = nil
p v&.partition { |x| x > 2 }
p v&.group_by { |x| x > 2 }
