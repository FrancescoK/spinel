# The existing builtin freshness proof still accepts fresh aliased overrides.
class FreshInspection
  def inspect = +"a"
end
class AliasedInspection
  def get = +"b"
  alias inspect get
end
receivers = [FreshInspection.new, AliasedInspection.new]
value = receivers[1].inspect
other = value
other << "!"
p value, other, value.equal?(other)
