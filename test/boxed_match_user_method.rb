# `x.match?(/re/)` on a boxed receiver is String#match? (or a Symbol's)
# only for those; a program class's own match? answers for its objects,
# and may answer anything. tzinfo's TimezoneProxy-style Zone#match? and
# activesupport's Chars delegate match?. The String fast path took every
# boxed receiver: such an object raised NoMethodError, and where the call
# was typed boxed, the C did not compile.
class Zone
  def initialize(n) = @n = n
  def match?(re) = re.match?(@n) ? :hit : nil
end
def m(x) = x.match?(/ab/)
p m("xaby")
p m(:ab)
p m(Zone.new("ab"))
p m(Zone.new("q"))
p(m("zz") ? 1 : 2)
