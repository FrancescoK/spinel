# The poly dispatch drops an arm whose parameter cannot take the argument --
# a String against a non-String, an object against a scalar, two unrelated
# object classes -- because passing the temp raw would be a hard C error, not
# a coercion that works. Two different CONTAINER kinds were missing from that
# list, so a `merge` seeded Hash[String, String] on an unrelated class took the
# arm for a plain Hash's call and the build stopped inside that class. The
# collapsed-keyword slot had made the same argument all along (#4172).
# an arm whose parameter CAN take the argument keeps it
# spinel: rbs-seed-run
class Flash
  def merge(other)
    Flash.new
  end
  def to_s; "flash"; end
end

class Taker
  def merge(other)
    other.keys.map(&:to_s).sort
  end
end

def patch(headers: {}, env: {})
  headers.merge(env)
end

def pick(n)
  n > 0 ? Taker.new : Flash.new
end

# Hash#inspect changed spelling in Ruby 3.4; compare sorted pair lists so this
# file reads the same under either.
def pairs(h) = h.map { |k, v| "#{k}=#{v}" }.sort
p pairs(patch(headers: { "A" => "1" }, env: { b: 2 }))
p pairs(patch(headers: { "A" => "1" }, env: { "B" => "2" }))
p pick(1).merge({ b: 2 })
