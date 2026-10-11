# `recv.attr ||= value` and `&&=` on a receiver that may be one of several
# classes (here, read out of an Array or a Hash of mixed values): the reader,
# then the writer when the test says so, on the receiver evaluated once. The
# expression's value is the reader's answer or the value assigned, never the
# writer's own return value.
class Constant
  attr_accessor :is_alias_for
  def b = @b
  def b=(v)
    @b = v * 2
    :ignored
  end
end

class NormalModule
  attr_accessor :is_alias_for, :b
end

$picks = 0
def pick(i) = ($picks += 1; [Constant.new, NormalModule.new][i])

known = pick(0)
p(known.is_alias_for ||= :target)
p(known.is_alias_for ||= :other)
p known.is_alias_for
p(known.is_alias_for &&= :changed)
p known.is_alias_for

p(known.b ||= 4)
p known.b

pick(1).is_alias_for ||= 1
p $picks

m = pick(1)
m.is_alias_for = false
m.is_alias_for ||= :t
p m.is_alias_for
m.is_alias_for &&= nil
p m.is_alias_for
m.is_alias_for &&= 9
p m.is_alias_for

constants = { "PI" => Constant.new, "name" => "a String" }
c = constants["PI"]
c.is_alias_for ||= [1]
c.is_alias_for ||= [2]
p c.is_alias_for

def merge(object, lines)
  object.is_alias_for ||= lines
end
p merge(pick(0), ["a"])
p merge(known, ["b"])
