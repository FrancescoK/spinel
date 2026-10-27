# spinel: rbs-seed-run
# An empty {} handed through a ** rest to a keyword whose signature types it
# a Hash is that keyword's hash: the method's writes reach the caller's {},
# as in CRuby, where it was a converted copy that took them in its place.
class KwRestTypedFill
  def outer(**kw) = inner(**kw)
  def inner(into: nil) = (into[:v] = 1)
end

b = {}
KwRestTypedFill.new.outer(into: b)
p b
c = {k: 0}
KwRestTypedFill.new.outer(into: c)
p c
