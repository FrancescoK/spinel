# Under --int-overflow=promote an Integer slot that can hold nil (an ivar,
# a global, a class variable, a local, a method's parameter) is widened to
# the box, while a block parameter it feeds keeps its Integer type, whose nil
# is the slot's sentinel. The value was unboxed with `.v.i`, which read the 0
# under the nil tag: `y(@u) { |a| a }` bound 0 for a nil @u. Through a
# yield into a required, an optional, a post and a keyword block parameter,
# and through instance_exec, as the generated call-binding probe found it.
def y(a) = yield(a)
def y2(a, b) = yield(a, b)
def yk(a) = yield(k: a)
def setu = (@u = 0)
def setg = ($g = 0)
@u = nil
$g = nil
p(y(@u) { |a| a })
p(y($g) { |a| a })
p(y2(1, @u) { |a, b = 3| [a, b] })
p(y2(@u, 1) { |a, *r, b| [a, r, b] })
p(y2(1, @u) { |a, *r, b| [a, r, b] })
p(yk(@u) { |k:| k })
p(Object.new.instance_exec(@u) { |a| a })
p(Object.new.instance_exec(@u, 2, **{}) { |a, *r, b, **nil| [a, r, b] })
p(Object.new.instance_exec(1, @u) { |a, b = 3| [a, b] })
def lo(v)
  x = nil
  x = v if v > 5
  y(x) { |a| a }
end
p lo(1)
p lo(7)
def pa(v = nil) = y(v) { |a| a }
p pa(3)
p pa
class C
  @@c = nil
  def self.setc = (@@c = 0)
  def self.c = y(@@c) { |a| a }
  def self.y(a) = yield(a)
end
p C.c
@u = 4
p(y(@u) { |a| a + 1 })
