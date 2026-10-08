# A hash crossing a SEEDED boundary whose variant differs from the caller's.
# The parameter's type came from its bare `{}` default while the caller passed
# a String-keyed hash, so the boxed value was unboxed into the seeded slot with
# a pointer cast. The variants are separate C structs: the KEYS lined up (both
# are str-keyed) and every VALUE read as the zero of another type -- "7" became
# "" and "2" became 0, with no TypeError and no diagnostic (#3998).
#
# Note a limit this exposes rather than fixes: two variants cannot be the same
# object, so a hash that has to change variant here is REBUILT, and a later
# mutation through the seeded slot is not seen by the caller's binding. A hash
# already at the seeded variant keeps its identity, which is the case below.
# spinel: rbs-seed-run
class Req
  def initialize
    @params = {}
  end

  def params
    @params
  end

  def params=(v)
    @params = v
  end

  def self.with_default(params = {})
    r = new
    r.params = params
    r
  end
end

d = Req.with_default({ "id" => "7", "page" => "2" })
d.params.each { |k, v| puts "key=" + k.inspect + " class=" + k.class.to_s + " val=" + v.to_s }
p d.params
p d.params["id"]
p d.params.size

# a mixed-value hash is already the seeded variant, so it crosses as itself
src = { "a" => 1, "b" => "two" }
e = Req.with_default(src)
e.params["c"] = :three
p e.params
p src.equal?(e.params)
p src
