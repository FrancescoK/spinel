# The poly setter dispatch emits an arm per class that answers the name. The
# ATTR arms have always skipped a class whose slot cannot hold the value -- the
# runtime object is not that class anyway -- and the METHOD arms did not: an
# unrelated class's `def session=`, seeded `(Integer?)` by an .rbs that says
# nothing about this call site, got an arm passing it an object pointer, and
# the build stopped on a class the receiver can never be. Supplying an .rbs
# changed which method the call resolved to (#4171).
# a real setter that CAN take the value keeps its arm, and one that cannot
# raises for a receiver of that class rather than miscompiling
# spinel: rbs-seed-run
class Base
  attr_accessor :session
end
class A < Base; end
class B < Base; end

class Sess
  def name; "sess"; end
end

class Other
  def session=(value)
    @session = value
  end
  def session; @session; end
end

class Taker
  def session=(value)
    @kept = value
  end
  def kept; @kept; end
end

def pick(n)
  case n
  when 0 then A.new
  when 1 then B.new
  else Taker.new
  end
end

c = pick(0)
c.session = Sess.new
p c.session.name

t = pick(2)
t.session = Sess.new
p t.kept.name

o = Other.new
o.session = 5
p o.session
