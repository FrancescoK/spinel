# A block whose last statement writes an element (`h[k] ||= v`, `&&=`, `+=`)
# answers the element's value to the yield that reads it. The statement form
# of the write was spliced where the value was read, and the C did not
# build (#9123's cache: `@store[key] ||= render`).
def g = yield

h = {"k" => +"a"}
p g { h["k"] ||= "v" }
p g { h["z"] ||= "new" }
p g { h["k"] &&= "w" }
p g { h["k"] += "!" }
p h

class Cache
  def initialize
    @store = {}
  end

  def run = yield

  def fetch(key)
    run { @store[key] ||= "rendered #{key}" }
  end
end
c = Cache.new
p c.fetch("a"), c.fetch("a"), c.fetch("b")

counts = [0, 0]
p g { counts[1] += 5 }
p counts
