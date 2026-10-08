# Receiverless raise and fail can return through the enclosing class's own
# methods, included modules and superclass. An earlier shared read must not
# replace a returning override's value with a stale handle.
S = +"s"
S << "!"
def source = S

class OwnRaise
  def raise(m) = S
  def fail(m) = +"own"
  def pick(f)
    source
    f ? S : raise("x")
  end
  def pick_fail(f)
    source
    f ? S : (fail("x"))
  end
end
own = OwnRaise.new
p own.pick(false).equal?(S)
p own.pick_fail(false)
p own.pick_fail(false).equal?(S)
p own.pick_fail(true).equal?(S)

module RaisingMember
  def raise(m) = +"included"
  def fail(m) = nil
end
class IncludedRaise
  include RaisingMember
  def pick(f)
    source
    f ? S : raise("x")
  end
  def pick_fail(f)
    source
    f ? S : fail("x")
  end
end
included = IncludedRaise.new
p included.pick(false)
p included.pick(false).equal?(S)
p included.pick(true).equal?(S)
p included.pick_fail(false)
p included.pick_fail(false).equal?(S)
p included.pick_fail(true).equal?(S)

class RaisingBase
  def raise(m) = +"inherited"
  def fail(m) = S
end
class InheritedRaise < RaisingBase
  def pick(f)
    source
    f ? S : raise("x")
  end
  def pick_fail(f)
    source
    f ? S : fail("x")
  end
end
inherited = InheritedRaise.new
p inherited.pick(false)
p inherited.pick(false).equal?(S)
p inherited.pick(true).equal?(S)
p inherited.pick_fail(false).equal?(S)
p S
