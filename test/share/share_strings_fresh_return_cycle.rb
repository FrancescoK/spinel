# A method whose answer goes around a cycle back to itself answers a new
# String when every way out of the cycle does: an inspect that calls
# inspect on a box that may hold its own object, beside others that build
# their Strings. Kept beside a String changed through another name, each is
# a new handle, a change through it showing through its other names.
$all = []
b = +"buf"; $all << b; b << "!"
class Env
  def initialize(n) = @name = n
  def inspect = @name.inspect
end
class Pt
  def inspect = "#<Pt #{object_id > 0}>"
end
items = [Env.new(ARGV.size > 0 ? 1 : +"dev"), Env.new(Env.new(:inner)), Pt.new, :sym]
r = items.map { |x| x.inspect }
r.each { |e| $all << e; e << "." }
p r

p $all
