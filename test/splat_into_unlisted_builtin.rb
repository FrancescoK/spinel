# A splat into a builtin method the splat lists leave out reaches it as
# separate arguments, by the counts CRuby's tables give the method: the
# search methods answered nil or raised for the Array the splat is.
def fi(a, *r) = a.find_index(*r)
def as(a, *r) = a.assoc(*r)
def ra(a, *r) = a.rassoc(*r)
def hk(h, *r) = h.key(*r)
def ha(h, *r) = h.assoc(*r)
def cy(a, *r) = a.cycle(*r).first(3)
def sc(s, *r) = s.scan(*r)
def mt(s, *r) = s.match?(*r)
def cc(s, *r) = s.casecmp?(*r)
def ch(s, *r) = s.chomp(*r)
def mm(a, *r) = a.minmax(*r)
def cl(n, *r) = n.clamp(*r)
def dm(n, *r) = n.divmod(*r)
p fi([3, 1, 2, 1], 1), fi([3, 1], 9), as([[1, :a], [2, :b]], 2), ra([[1, :a]], :a)
p hk({a: 1}, 1), ha({a: 1}, :a), cy([1, 2]), sc("a1b2", /\d/), mt("abc", /b/)
p cc("A", "a"), ch("ab\n"), ch("abx", "x"), mm([3, 1]), cl(5, 1, 3), dm(7, 2)
x = [3, 1].find_index(*[1])
p x
# a local that holds no Array spreads as one argument, and a method of the
# program's own under a builtin's name takes the splat as before
n = [2, "x"][0]
p [1, 2, 3].find_index(*n), 7.divmod(*n)
class Tally
  def add(a, b) = a + b
end
pair = [n, 5]
p Tally.new.add(*pair), Tally.new.add(*n, 1)
