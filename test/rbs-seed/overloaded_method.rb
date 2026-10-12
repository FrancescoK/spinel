# spinel: rbs-seed-run
# An overloaded method seeds nothing. OvWrap.wrap's first overload takes nil
# (as activesupport's Array.wrap does), and seeding it alone pinned the
# parameter to nil, which the calls with an Integer and an Array contradict.
# OvPick#pick is declared in one .rbs and given a second overload with
# `| ...` in another; the two halves were two declarations of one method
# with different signatures, which is refused.
class OvWrap
  def self.wrap(object)
    if object.nil?
      []
    elsif object.respond_to?(:to_ary)
      object.to_ary || [object]
    else
      [object]
    end
  end
end

class OvPick
  def pick(x) = x
end

p OvWrap.wrap(nil), OvWrap.wrap(3), OvWrap.wrap([4, 5])
o = OvPick.new
p o.pick(1), o.pick("a")
