# A boxed Array reached through a dispatch (a program class defines the
# same block methods) is walked live, as CRuby walks an Array: the block
# sees what it appends, and a shortened receiver ends the walk
class Bag
  def each(&b) = [1].each(&b)
  def map(&b) = [1].map(&b)
  def select(&b) = [1].select(&b)
  def reject(&b) = [1]
  def reverse_each(&b) = nil
  def sort_by(&b) = [1]
  def uniq(&b) = [1]
  def sum(&b) = 1
  def find_index(&b) = 0
  def count(&b) = 1
  def any?(&b) = false
  def find(&b) = nil
  def all?(&b) = true
  def none?(&b) = true
  def each_with_index(&b) = nil
end
def mk(x) = [x, Bag.new].first
a = mk([1, 2, 3, 4]); out = []; a.reverse_each { |x| a.pop(2) if x == 4; out << x }; p out
a = mk([1, 2, 3, 4]); out = []; a.reverse_each { |x| a << 9 if x == 4; out << x }; p out
a = mk([3, 1, 2]); p a.sort_by { |x| a << 0 if x == 3; x }
a = mk([1, 2, 1]); p a.uniq { |x| a << 5 if x == 2; x }
a = mk([1, 2]); p a.sum { |x| a << 10 if x == 1; x }
a = mk([1, 2]); p a.find_index { |x| a << 7 if x == 1; x == 7 }
a = mk([1, 2]); p a.all? { |x| a << 0 if x == 1; x > 0 }
a = mk([1, 2]); p a.none? { |x| a << 0 if x == 1; x == 0 }
a = mk(%w[a b]); p a.map { |x| a << "c" if x == "a"; x.upcase }
a = mk(%i[a b]); out = []; a.each { |x| a << :c if x == :a; out << x }; p out
a = mk([1.5, 2.5]); out = []; a.each { |x| a << 3.5 if x == 1.5; out << x }; p out
a = mk([1, 2, 3, 4]); p a.reject { |x| a.shift if x == 1; x.even? }
a = mk([1, 2, 3, 4]); p a.select { |x| a.clear if x == 2; true }
a = mk([1, 2]); out = []; a.each_with_index { |x, i| a.unshift(0) if i == 0; out << [x, i] }; p out
h = mk({a: 1}); out = []; h.each { |k, v| out << [k, v] }; p out
r = mk(1..3); p r.map { |x| x * 2 }
e = mk([1, 2].each); p e.map { |x| x + 1 }
a = mk([1, 2]); p a.each { |x| x }
a = mk([1, 2]); out = []; a.each { |x| a << 3 if x == 1; out << x }; p out
a = mk([1, 2]); out = []; a.each_with_index { |x, i| a << 3 if x == 1; out << [x, i] }; p out
a = mk([1, 2]); p a.map { |x| a << 3 if x == 1; x }
a = mk([1, 2]); p a.select { |x| a << 3 if x == 1; true }
a = mk([1, 2]); p a.count { |x| a << 3 if x == 1; true }
a = mk([1, 2]); p a.any? { |x| a << 3 if x == 1; x == 3 }
a = mk([1, 2]); p a.find { |x| a << 3 if x == 1; x == 3 }
a = mk([1, 2, 3, 4]); out = []; a.each { |x| a.delete(x) if x == 2; out << x }; p out
a = mk([1, 2, 3, 4]); out = []; a.each { |x| a.pop if x == 2; out << x }; p out
a = mk([1, 2, 3, 4]); p a.map { |x| a.pop if x == 2; x }
a = mk([1, 2, 3, 4]); p a.select { |x| a[0] = 9 if x == 1; true }
a = mk([1, 2, 3, 4]); p a.reject { |x| a[0] = 9 if x == 1; false }
# the element a block removes stays alive while the block still reads it
def junk = 200.times.map { |j| "z#{j}" * 2 }
a = mk((0...300).map { |i| "q#{i}" * 2 }); n = 0; a.each { |x| a.delete(x); junk; n += x.size }; p n
a = mk((0...300).map { |i| "q#{i}" }); p a.map { |x| a.delete(x); junk; x + "!" }.size
