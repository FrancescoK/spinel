# spinel: share
# spinel: gc-stress
# An endless String Range (last nil) walks by String#succ whatever its begin
# is: a literal, a String.new, a parameter, an ivar or a call's value, in a
# local, an ivar or a parameter. It was the literal's special case: every other
# begin sent first(n), each, lazy, step and the rest through the member Array,
# which an endless range cannot make (RangeError). The walks stop where the
# block or the count says.
def walks(r)
  p r.first(2), r.first(0), r.first, r.take(3), r.take(0)
  r.each { |x| print x; break if x > "d" }
  puts
  for x in r do print x; break if x > "d" end
  puts
  r.each_entry { |x| print x; break if x > "d" }
  puts
  r.step(2) { |x| print x; break if x > "g" }
  puts
  p r.each.first(2), r.each.next
  p r.lazy.first(2), r.lazy.map { |x| x * 2 }.first(2), r.lazy.select { |x| x.size == 1 }.first(2)
  p r.step(2).first(3)
  p r.take_while { |x| x < "e" }
  r.each_with_index { |x, i| print x, i; break if i == 2 }
  puts
  p r.each_with_index.first(2), r.each_slice(2).first(2), r.each_cons(2).first(2), r.each_entry.first(2)
  p r.find { |x| x > "d" }, r.detect { |x| x > "d" }, r.find_index { |x| x > "d" }, r.find_index("d")
  e = r.each
  p e.next, e.next, e.peek
  p r.each { |x| break x * 2 if x == "c" }
end
walks(("b"..))
walks(String.new("b")..)
a = String.new("b")
walks(a..)
r = (a..)
walks(r)
def start = String.new("b")
returned = (start..)
walks(returned)
walks(start..)
class Holder
  def initialize(s) = (@r = (s..))
  def go = walks(@r)
end
Holder.new(String.new("b")).go
def param_begin(s)
  r = (s..)
  p r.first(2), r.take(2), r.lazy.first(2)
  r.each { |x| print x; break if x > "d" }
  puts
end
param_begin(String.new("b"))
p (r % 3).first(2), (("a"..) % 2).first(3)
# a bounded range keeps its members, and a beginless one its errors
q = ("a".."e")
p q.first(2), q.take(9), q.first(0), q.each.first(2), q.lazy.map { |x| x * 2 }.first(2)
q.each { |x| print x }
puts
for x in q do print x end
puts
p q.step(2).to_a, q.each_slice(2).to_a, q.each_with_index.to_a, q.find_index("c")
begin; (.."e").first(2); rescue => e; p e.class, e.message; end
begin; (.."e").take(2); rescue => e; p e.class, e.message; end
begin; (.."e").each { }; rescue => e; p e.class, e.message; end
begin; r.first(-1); rescue => e; p e.class, e.message; end
begin; r.take(-1); rescue => e; p e.class, e.message; end
p ("a"..."c").first(5), ("e".."a").first(2), ("9".."11").first(5)
p ("a"..).first(30).last, ("az"..).first(3)
# operands that allocate are evaluated before the Enumerator is built, and a
# body that changes its member does not move the walk
def arg(s) = (s * 2)[0, 1] + "z"
q = ("a".."zz")
3.times { p q.find_index(arg("d")), q.each_slice(arg("d").size).first(1), q.each_cons(arg("d").size).first(1) }
b = String.new("b")
(b..).each { |x| x << "!"; print x, " "; break if x.start_with?("d") }
puts
# a to_a the program wrote is the member Array's, and an endless Range has none
e = (String.new("a")..)
begin; p e.to_a.each_slice(2).first(1); rescue => ex; p ex.class; end
begin; p e.to_a.find_index("c"); rescue => ex; p ex.class; end
begin; p e.to_a.each_with_index.first(1); rescue => ex; p ex.class; end
# a find_index that misses is nil, an endless range's step and % keep their
# labels and their size (nil), and a Float stride raises where it is walked
miss = q.find_index("zzzz")
p miss, miss.nil?, q.find_index("b") + 1
p (r % 3), r.step(2), (r % 2).size, r.step(2).size, r.each.size
f = r % 1.5
p f, f.size
begin; f.first(2); rescue => ex; p ex.class, ex.message; end
# an endless range's Enumerators have no size either, nor do those built on them
en = (String.new("a")..)
p en.each.with_index.size, en.each_slice(2).size, en.each_cons(2).size, en.each_with_index.size, en.each_entry.size
p en.step(2).size, (en % 2).size, en.step(2).with_index.size, en.step(2).each_slice(2).size
